#!perl

use warnings;
use strict;

require 't/LintTest.pl';

checkit( [
    [ 'text-unclosed-entity' => qr/Entity &ouml; is missing its closing semicolon/ ],
], [<DATA>] );

__DATA__
<html>
    <head>
        <title>Ace of &spades;: A tribute to Mot&ouml;rhead.</title>
    </head>
    <body bgcolor="white">
        Mot&oumlrhead rulez!
    </body>
</html>
