#!perl -Tw

use warnings;
use strict;

use Test::More tests => 3;

BEGIN {
    use_ok( 'HTML::Lint' );
}
BEGIN {
    use_ok( 'Test::HTML::Lint' );
}

is( $HTML::Lint::VERSION, $Test::HTML::Lint::VERSION, "HTML::Lint and Test::HTML::Lint versions match" );
