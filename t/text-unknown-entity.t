#!perl

use warnings;
use strict;

require 't/LintTest.pl';

checkit( [
    [ 'text-unknown-entity' => qr/Entity &metalhorns; is unknown/ ],
], [<DATA>] );

__DATA__
<html>
    <head>
        <title>Ace of &spades;: A tribute to Mot&ouml;rhead. &#174; &metalhorns;</title>
    </head>
    <body bgcolor="white">
        Thanks for visiting Ace of &#9824; <!-- Numeric version of &spades; -->
    </body>
</html>
