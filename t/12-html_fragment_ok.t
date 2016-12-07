use warnings;
use strict;
require 't/LintTest.pl';

# This test passes the HTML into html_ok, which expects a fully-formed
# HTML document.

checkit( [
    [ 'elem-img-alt-missing' => 'Set #1 (4:5) <img src="alpha.jpg"> does not have ALT text defined' ],
    [ 'elem-input-alt-missing' => 'Set #1 (5:5) <input name="" type="image"> does not have non-blank ALT text defined' ],    
    [ 'doc-tag-required'     => 'Set #1 (7:1) <head> tag is required' ],
    [ 'doc-tag-required'     => 'Set #1 (7:1) <html> tag is required' ],
    [ 'doc-tag-required'     => 'Set #1 (7:1) <title> tag is required' ],
], [<DATA>] );

__DATA__
<body>
<p>
    This is a valid fragment, but an incomplete document.
    <img src="alpha.jpg" height="21" width="12">
    <input type="image">
</p>
</body>
