use warnings;
use strict;
require 't/LintTest.pl';

checkit( [
    [ 'config-unknown-directive' => qr/Unknown directive "bongo"$/ ],
], [<DATA>] );

__DATA__
<html>
    <head>
        <title>Test stuff</title>
    </head>
    <body bgcolor="white">
        <!-- html-lint bongo: on -->
    </body>
</html>
