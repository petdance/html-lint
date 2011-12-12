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

        <!-- lint:disable elem-img-sizes-missing -->
        <img src="beta.jpg" />

        <!-- lint:disable --><!-- Disables all by default -->
        <img src="gamma.jpg" />
        <gooble darble="fungo" />

        <!-- lint:enable elem-img-alt-missing -->
        <img src="delta.jpg">

        <!-- lint:enable -->
        <img src="epsilon.jpg">
    </body>
</html>
