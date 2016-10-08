use strict;
use Test::More;
BEGIN { plan tests => 4 };
BEGIN { $ENV{PERL_JSON_BACKEND} = 0; }
use JSON::PP;

eval { decode_json(qq({"foo":{"bar":42})) };
like $@ => qr/offset 17/; # 16

eval { decode_json(qq(["foo",{"bar":42})) };
like $@ => qr/offset 17/;

eval { decode_json(qq(["foo",{"bar":42}"])) };
like $@ => qr/offset 17/; # 18

eval { decode_json(qq({"foo":{"bar":42}"})) };
like $@ => qr/offset 17/;

