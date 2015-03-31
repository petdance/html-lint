use warnings;
use strict;
require 't/LintTest.pl';

checkit( [
    [ 'elem-input-alt-missing' => qr/<input name="dave" type="image"> does not have ALT text defined/i ],
    [ 'elem-input-alt-missing' => qr/<input name="bob" type="image"> does not have ALT text defined/i ],
    [ 'elem-input-alt-missing' => qr/<input name="" type="image"> does not have ALT text defined/i ],
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
            <input name="bob" type="image" />
            <input type="image" />
            <input name="ok" type="image" alt="Blah blah" />
            <input type="text" name="bongo" />
        </form>
    </BODY>
</HTML>
