#!perl -Tw

use warnings;
use strict;

# The test is not that html_ok() works, but that the tests=>1 gets
# acts as it should.

use Test::HTML::Lint tests=>1;

my $chunk = "<P>This is a fine chunk of code</P>";

html_ok( $chunk );
