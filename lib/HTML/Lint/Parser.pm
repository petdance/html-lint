package HTML::Lint::Parser;

use warnings;
use strict;

use HTML::Parser 3.20;
use HTML::Tagset 3.03;

use HTML::Lint::HTML4 qw( %isKnownAttribute %isRequired %isNonrepeatable %isObsolete );
use HTML::Entities qw( %char2entity );

use base 'HTML::Parser';

=head1 NAME

HTML::Lint::Parser - Parser for HTML::Lint.  No user-serviceable parts inside.

=head1 VERSION

Version 2.22

=cut

our $VERSION = '2.22';

=head1 SYNOPSIS

See L<HTML::Lint> for all the gory details.

=head1 METHODS

=head2 new( $gripe )

Constructor for the main parsing object.  The I<$gripe> argument
is a coderef to a function that can handle errors from the parser.
It is only ever (so far) C<HTML::Lint::gripe()>.

=cut

sub new {
    my $class = shift;
    my $gripe = shift;

    my $self =
        HTML::Parser->new(
            api_version => 3,
            start_document_h   => [ \&_start_document, 'self' ],
            end_document_h     => [ \&_end_document,   'self,line,column' ],
            start_h            => [ \&_start,          'self,tagname,line,column,@attr' ],
            end_h              => [ \&_end,            'self,tagname,line,column,tokenpos,@attr' ],
            comment_h          => [ \&_comment,        'self,tagname,line,column,text' ],
            text_h             => [ \&_text,           'self,text' ],
            strict_names       => 0,
            empty_element_tags => 1,
        );
    bless $self, $class;

    $self->{_gripe}      = $gripe;
    $self->{_stack}      = [];
    $self->{_directives} = {};

    return $self;
}

=head2 $parser->gripe( $errorcode, [ arg1=>val1, ...] )

Calls the passed-in gripe function.

If a given directive has been set to turn off a given message, then
the parent gripe never gets called.

=cut

sub gripe {
    my $self      = shift;
    my $errorcode = shift;

    if ( $self->_displayable( $errorcode ) ) {
        $self->{_gripe}->( $errorcode, @_ );
    }

    return;
}

sub _displayable {
    my $self      = shift;
    my $errorcode = shift;

    my $directives = $self->{_directives};
    if ( not defined $directives->{$errorcode} ) {
        return 1;
    }
    else {
        return $directives->{$errorcode};
    }
}

sub _start_document {
    return;
}

sub _end_document {
    my ($self,$line,$column) = @_;

    for my $tag ( keys %isRequired ) {
        if ( !$self->{_first_seen}->{$tag} ) {
            $self->gripe( 'doc-tag-required', tag => $tag );
        }
    }

    return;
}

sub _start {
    my ($self,$tag,$line,$column,@attr) = @_;

    $self->{_line} = $line;
    $self->{_column} = $column;

    my $validattr = $isKnownAttribute{ $tag };
    if ( $validattr ) {
        my %seen;
        my $i = 0;
        while ( $i < @attr ) {
            my ($attr,$val) = @attr[$i++,$i++];
            if ( $seen{$attr}++ ) {
                $self->gripe( 'attr-repeated', tag => $tag, attr => $attr );
            }

            if ( !$validattr->{$attr} ) {
                $self->gripe( 'attr-unknown', tag => $tag, attr => $attr );
            }
        } # while attribs
    }
    else {
        $self->gripe( 'elem-unknown', tag => $tag );
    }
    $self->_element_push( $tag ) unless $HTML::Tagset::emptyElement{ $tag };

    if ( my $where = $self->{_first_seen}{$tag} ) {
        if ( $isNonrepeatable{$tag} ) {
            $self->gripe( 'elem-nonrepeatable',
                            tag => $tag,
                            where => HTML::Lint::Error::where( @{$where} )
                        );
        }
    }
    else {
        $self->{_first_seen}{$tag} = [$line,$column];
    }

    # Call any other overloaded func
    my $tagfunc = "_start_$tag";
    if ( $self->can($tagfunc) ) {
        $self->$tagfunc( $tag, @attr );
    }

    return;
}

sub _text {
    my ($self,$text) = @_;

    while ( $text =~ /&(?![#0-9a-z])/ig ) {
        $self->gripe( 'text-use-entity', char => '&', entity => '&amp;' );
    }

    while ( $text =~ /([^\x09\x0A\x0D -~])/g ) {
        my $bad = $1;
        $self->gripe(
            'text-use-entity',
                char => sprintf( '\x%02lX', ord($bad) ),
                entity => $char2entity{ $bad },
        );
    }

    if ( not $self->{_unclosed_entities_regex} ) {
        # Get Gisle's list
        my @entities = sort keys %HTML::Entities::entity2char;

        # Strip his semicolons
        s/;$// for @entities;

        # Build a regex
        my $entities = join( '|', @entities );
        $self->{_unclosed_entities_regex} = qr/&($entities)(?!;)/;

        $self->{_entity_lookup} = { map { ($_,1) } @entities };
    }

    while ( $text =~ m/$self->{_unclosed_entities_regex}/g ) {
        my $ent = $1;
        $self->gripe( 'text-unclosed-entity', entity => "&$ent;" );
    }

    while ( $text =~ m/&([^;]+);/g ) {
        my $ent = $1;

        # Numeric entities are fine, if they're not too large.
        if ( $ent =~ /^#(\d+)$/ ) {
            if ( $1 > 65536 ) {
                $self->gripe( 'text-invalid-entity', entity => "&$ent;" );
            }
            next;
        }

        # Hex entities are fine, if they're not too large.
        if ( $ent =~ /^#x([\dA-F]+)$/i ) {
            if ( length($1) > 4 ) {
                $self->gripe( 'text-invalid-entity', entity => "&$ent;" );
            }
            next;
        }

        # If it's not a numeric entity, then check the lookup table.
        if ( !exists $self->{_entity_lookup}{$ent} ) {
            $self->gripe( 'text-unknown-entity', entity => "&$ent;" );
        }
    }

    return;
}

sub _comment {
    my ($self,$tagname,$line,$column,$text) = @_;

    # Look for the html-lint directives
    if ( $tagname =~ m/^\s*html-lint\s*(.+)\s*$/ ) {
        my $text = $1;

        my @commands = split( /\s*,\s*/, $text );

        for my $command ( @commands ) {
            my ($directive,$value) = split( /\s*:\s*/, $command, 2 );
            _trim($_) for ($directive,$value);

            if ( ($directive ne 'all') &&
                ( not exists $HTML::Lint::Error::errors{ $directive } ) ) {
                $self->gripe( 'config-unknown-directive',
                    directive => $directive,
                    where     => HTML::Lint::Error::where($line,$column)
                );
                next;
            }

            my $normalized_value = _normalize_value( $value );
            if ( !defined($normalized_value) ) {
                $self->gripe( 'config-unknown-value',
                    directive => $directive,
                    value     => $value,
                    where     => HTML::Lint::Error::where($line,$column)
                );
                next;
            }

            if ( $directive eq 'all' ) {
                for my $err ( keys %HTML::Lint::Error::errors ) {
                    $self->_set_directive( $err, $normalized_value );
                }
            }
            else {
                $self->_set_directive( $directive, $normalized_value );
            }
        }
    }

    return;
}

sub _set_directive {
    my $self  = shift;
    my $which = shift;
    my $what  = shift;

    $self->{_directives}{$which} = $what;

    return;
}


sub _normalize_value {
    my $what = shift;

    $what = _trim( $what );
    return 1 if $what =~ /^(?:1|on|true)$/;
    return 0 if $what =~ /^(?:0|off|false)$/;
    return undef;
}

sub _trim {
    $_[0] =~ s/^\s+//;
    $_[0] =~ s/\s+$//;

    return $_[0];
}

sub _end {
    my ($self,$tag,$line,$column,$tokenpos,@attr) = @_;

    $self->{_line} = $line;
    $self->{_column} = $column;

    if ( !$tokenpos ) {
        # This is a dummy end event for something like <img />.
        # Do nothing.
    }
    elsif ( $HTML::Tagset::emptyElement{ $tag } ) {
        $self->gripe( 'elem-empty-but-closed', tag => $tag );
    }
    else {
        if ( $self->_in_context($tag) ) {
            my @leftovers = $self->_element_pop_back_to($tag);
            for ( @leftovers ) {
                my ($tag,$line,$col) = @{$_};
                $self->gripe( 'elem-unclosed', tag => $tag,
                        where => HTML::Lint::Error::where($line,$col) )
                        unless $HTML::Tagset::optionalEndTag{$tag};
            } # for
        }
        else {
            $self->gripe( 'elem-unopened', tag => $tag );
        }
    } # is empty element

    # Call any other overloaded func
    my $tagfunc = "_end_$tag";
    if ( $self->can($tagfunc) ) {
        $self->$tagfunc( $tag, $line );
    }

    return;
}

sub _element_push {
    my $self = shift;
    for ( @_ ) {
        push( @{$self->{_stack}}, [$_,$self->{_line},$self->{_column}] );
    } # while

    return;
}

sub _find_tag_in_stack {
    my $self = shift;
    my $tag = shift;
    my $stack = $self->{_stack};

    my $offset = @{$stack} - 1;
    while ( $offset >= 0 ) {
        if ( $stack->[$offset][0] eq $tag ) {
            return $offset;
        }
        --$offset;
    } # while

    return;
}

sub _element_pop_back_to {
    my $self = shift;
    my $tag = shift;

    my $offset = $self->_find_tag_in_stack($tag) or return;

    my @leftovers = splice( @{$self->{_stack}}, $offset + 1 );
    pop @{$self->{_stack}};

    return @leftovers;
}

sub _in_context {
    my $self = shift;
    my $tag = shift;

    my $offset = $self->_find_tag_in_stack($tag);
    return defined $offset;
}

# Overridden tag-specific stuff
sub _start_img {
    my ($self,$tag,%attr) = @_;

    my ($h,$w,$src) = @attr{qw( height width src )};
    if ( defined $h && defined $w ) {
        # Check sizes
    }
    else {
        $self->gripe( 'elem-img-sizes-missing', src=>$src );
    }
    if ( not defined $attr{alt} ) {
        $self->gripe( 'elem-img-alt-missing', src=>$src );
    }

    return;
}

sub _start_input {
    my ($self,$tag,%attr) = @_;

    my ($type,$alt) = @attr{qw( type alt )};
    if ( defined($type) && lc($type) eq 'image' ) {
        my $ok = defined($alt);
        if ( $ok ) {
            $alt =~ s/^ +//;
            $alt =~ s/ +$//;
            $ok = ($alt ne '');
        }
        if ( !$ok ) {
            my $name = $attr{name};
            $name = '' unless defined $name;
            $self->gripe( 'elem-input-alt-missing', name => $name );
        }
    }

    return;
}

1;
