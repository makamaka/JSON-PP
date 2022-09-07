# copied over from JSON::XS and modified to use JSON::PP

use strict;
use warnings;
use Test::More;
BEGIN { plan tests => 4 };

BEGIN { $ENV{PERL_JSON_BACKEND} = 0; }

use JSON::PP;

my $pp = JSON::PP->new->latin1->allow_nonref;

is($pp->encode ("\x{12}\x{b6}       "), "\"\\u0012\x{b6}       \"");
is($pp->encode ("\x{12}\x{b6}\x{abc}"), "\"\\u0012\x{b6}\\u0abc\"");

is($pp->decode ("\"\\u0012\x{b6}\""       ), "\x{12}\x{b6}");
is($pp->decode ("\"\\u0012\x{b6}\\u0abc\""), "\x{12}\x{b6}\x{abc}");

