use warnings;
use strict;
require 't/LintTest.pl';

checkit( [
    [ 'elem-img-sizes-missing' => qr/\Q<IMG SRC="alpha.jpg"> tag has no HEIGHT and WIDTH attributes/i ],
    [ 'elem-img-alt-missing'   => qr/\Q<IMG SRC="alpha.jpg"> does not have ALT text defined/i ],

    [ 'elem-img-alt-missing'   => qr/\Q<IMG SRC="beta.jpg"> does not have ALT text defined/i ],

    # gamma.jpg will not error at all

    [ 'elem-img-alt-missing'   => qr/\Q<IMG SRC="delta.jpg"> does not have ALT text defined/i ],

    [ 'elem-img-sizes-missing' => qr/\Q<IMG SRC="epsilon.jpg"> tag has no HEIGHT and WIDTH attributes/i ],
    [ 'elem-img-alt-missing'   => qr/\Q<IMG SRC="epsilon.jpg"> does not have ALT text defined/i ],
], [<DATA>] );

__DATA__
<html>
    <head>
        <title>Test stuff</title>
    </head>
    <body bgcolor="white">
        <img src="alpha.jpg">

        <!-- html-lint elem-img-sizes-missing: on, attr-unknown: on -->
        <img src="beta.jpg" />

        <!-- html-lint all: off -->
        <img src="gamma.jpg" />
        <gooble darble="fungo" />

        <!-- html-lint elem-img-alt-missing: on -->
        <img src="delta.jpg">

        <!-- html-lint all: on -->
        <img src="epsilon.jpg">
    </body>
</html>
