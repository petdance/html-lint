use warnings;
use strict;
require 't/LintTest.pl';

checkit( [
    [ 'elem-img-alt-missing' => qr/<input type="image"> does not have ALT text defined/i ],
], [<DATA>] );

__DATA__
<html>
    <head>
        <title>Test stuff</title>
    </head>
    <body bgcolor="#ffffff">
        <p align="right">
            This is my paragraph
        </p>
        <form method="post" action="foo.php">
            <input type="image" name="dave" />
        </form>
    </BODY>
</HTML>
