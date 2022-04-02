# copied over from JSON::XS and modified to use JSON::PP

use strict;
use warnings;
use Test::More;
BEGIN { plan tests => 9 };

BEGIN { $ENV{PERL_JSON_BACKEND} = 0; }

use utf8;
use JSON::PP;


is (JSON::PP->new->allow_nonref (1)->utf8 (1)->encode ("ü"), "\"\xc3\xbc\"");
is (JSON::PP->new->allow_nonref (1)->encode ("ü"), "\"ü\"");
is (JSON::PP->new->allow_nonref (1)->ascii (1)->utf8 (1)->encode (chr 0x8000), '"\u8000"');
is (JSON::PP->new->allow_nonref (1)->ascii (1)->utf8 (1)->pretty (1)->encode (chr 0x10402), "\"\\ud801\\udc02\"\n");

eval { JSON::PP->new->allow_nonref (1)->utf8 (1)->decode ('"ü"') };
ok $@ =~ /malformed UTF-8/;

is (JSON::PP->new->allow_nonref (1)->decode ('"ü"'), "ü");
is (JSON::PP->new->allow_nonref (1)->decode ('"\u00fc"'), "ü");
is (JSON::PP->new->allow_nonref (1)->decode ('"\ud801\udc02' . "\x{10204}\""), "\x{10402}\x{10204}");
is (JSON::PP->new->allow_nonref (1)->decode ('"\"\n\\\\\r\t\f\b"'), "\"\012\\\015\011\014\010");

