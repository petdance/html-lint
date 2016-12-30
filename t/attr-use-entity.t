#!perl

use warnings;
use strict;
require 't/LintTest.pl';

checkit( [
    [ 'attr-use-entity'      => qr/Character "\\xF1" should be written as &ntilde;/ ],
    [ 'attr-use-entity'      => qr/Character "&" should be written as &amp;/ ],
    [ 'attr-use-entity'      => qr/Character "&" should be written as &amp;/ ],

], [<DATA>] );
    
__DATA__
<HTML>
    <HEAD>
	<TITLE>Test stuff</TITLE>
    </HEAD>
    <BODY BGCOLOR="We'll get to it ma�ana, which should really have an &ntilde;">
    <a href="#" title="Who wants a peanut butter & jelly?  Mot&ouml;rhead does!  They love rock & roll"></a>
    </BODY>
</HTML>
