use warnings;
use strict;
require 't/LintTest.pl';

checkit( [
    [ 'text-use-entity' => qr/Character "\\x0B" should be written as &#11;/i ],
    [ 'text-use-entity' => qr/Character "\\xF1" should be written as &ntilde;/i ],
], [<DATA>] );

__DATA__
<HTML>
    <HEAD>
        <TITLE>Test stuff</TITLE>
    </HEAD>
    <BODY BGCOLOR="white">
        Here's a non-entityable char [].
        <P>
        We'll get to it mañana, which should really have an &ntilde;.
    </BODY>
</HTML>
