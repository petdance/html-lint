use warnings;
use strict;
require 't/LintTest.pl';

checkit( [
    [ 'elem-img-sizes-missing' => qr/<IMG SRC="randal-thong\.jpg"> tag has no HEIGHT and WIDTH attributes./i ],
], [<DATA>] );
    
__DATA__
<HTML>
    <HEAD>
	<TITLE>Test stuff</TITLE>
    </HEAD>
    <BODY BGCOLOR="white">
	<P ALIGN=RIGHT>This is my paragraph</P>
	<IMG BORDER=3 HSPACE=12 SRC="randal-thong.jpg" ALT="Randal Schwartz in a thong">
    </BODY>
</HTML>
