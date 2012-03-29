use warnings;
use strict;
require 't/LintTest.pl';

checkit( [
    [ 'text-use-entity'      => qr/Character "\\x0B" should be written as &#11;/ ],
    [ 'text-use-entity'      => qr/Character "\\xF1" should be written as &ntilde;/ ],
    [ 'text-use-entity'      => qr/Character "&" should be written as &amp;/ ],
    [ 'text-use-entity'      => qr/Character "&" should be written as &amp;/ ],
    [ 'text-unclosed-entity' => qr/Entity &ouml; is missing its closing semicolon/ ],
], [<DATA>] );

__DATA__
<html>
    <head>
        <title>Test stuff</title>
    </head>
    <body bgcolor="white">
        Here's a non-entityable char [].
        <P>
        We'll get to it mañana, which should really have an &ntilde;.
        <p>
        Who wants a peanut butter & jelly?  Mot&oumlrhead does!  They love rock &
        roll!
        <p>
        Here's an awesome link to <a href="http://www.youtube.com/watch?v=8yLhA0ROGi4&feature=related">"You Better Swim"</a> from the SpongeBob movie.
    </body>
</html>
