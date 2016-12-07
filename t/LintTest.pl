use Test::More;
use HTML::Lint;

sub checkit {
    my @expected = @{+shift};
    my @linesets = @_;

    plan( tests => 2*(scalar @expected) + 4 );

    my $lint = new HTML::Lint;
    isa_ok( $lint, 'HTML::Lint', 'Created lint object' );

    my $n;
    for my $set ( @linesets ) {
        ++$n;
        $lint->newfile( "Set #$n" );
        $lint->parse( $_ ) for @$set;
        $lint->eof;
    }

    my @errors = $lint->errors();
    is( scalar @errors, scalar @expected, 'Right # of errors' );

    my $expected_found = 0;
    while ( @errors ) {
        my $error = shift @errors;
        isa_ok( $error, 'HTML::Lint::Error' );
        foreach my $exp (@expected) {
            my $match = $exp->[1];
            if ( ref $match eq "Regexp" && $error->as_string =~ /$match/) {
                $expected_found++;
                is( $error->errcode, $exp->[0], 'Error codes match' );
                last;
            }
            elsif ($error->as_string eq $match) {
                $expected_found++;
                is( $error->errcode, $exp->[0], 'Error codes match' );
                last;
            }

        }
    }

    my $dump;
    is( scalar @errors, 0, 'No unexpected errors found' ) or $dump = 1;
    is( $expected_found, scalar @expected, 'No expected errors missing' ) or $dump = 1;

    if ( $dump && @errors ) {
        diag( "Leftover errors..." );
        diag( $_->as_string ) for @errors;
    }
}

# Read in a set of sets of lines, where each "file" is separated by a
# blank line in <DATA>
sub get_paragraphed_files {
    local $/ = "";

    my @sets;

    while ( my $paragraph = <DATA> ) {
        my @lines = split /\n/, $paragraph;
        @lines = map { "$_\n" } @lines;
        push( @sets, [@lines] );
    }

    return @sets;
}

1; # happy
