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
        Mot&ouml;rhead rulez!
    </body>
</html>
