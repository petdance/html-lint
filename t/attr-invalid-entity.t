#!perl

use warnings;
use strict;

use lib 't/';
use Util;

checkit( [
    [ 'attr-invalid-entity' => qr/Entity &#8675309; is invalid/i ],
    [ 'attr-invalid-entity' => qr/Entity &#xdeadbeef; is invalid/ ],
], [<DATA>] );

__DATA__
<HTML>
    <HEAD>
        <TITLE>Test stuff</TITLE>
    </HEAD>
    <BODY BGCOLOR="Testing invalid entity &#8675309;">
    <p style="color: &#xdeadbeef;"></p>
    </BODY>
</HTML>
