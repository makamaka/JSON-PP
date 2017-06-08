use strict;
use Test::More;

BEGIN { plan tests => 7 };

BEGIN { $ENV{PERL_JSON_BACKEND} = 0; }

use JSON::PP;

BEGIN {
    use lib qw(t);
    use _unicode_handling;
}

no utf8;

my $json = JSON::PP->new->allow_nonref;

is($json->encode("\x00"), q|"\\u0000"|); # 00-08
is($json->encode("\x01"), q|"\\u0001"|); # 00-08
is($json->encode("\x07"), q|"\\u0007"|); # 00-08
is($json->encode("\x0e"), q|"\\u000e"|); # 0e-1f
is($json->encode("\x0f"), q|"\\u000f"|); # 0e-1f
is($json->encode("\x1f"), q|"\\u001f"|); # 0e-1f
is($json->encode("\x7f"), q|"\\u007f"|); # 7f
