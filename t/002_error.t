# copied over from JSON::PPdev::XS and modified to use JSON::PPdev

use strict;
use Test::More;
BEGIN { plan tests => 31 };

BEGIN { $ENV{PERL_JSON_BACKEND} = 0; }

BEGIN {
    use lib qw(t);
    use _unicode_handling;
}

use utf8;
use JSON::PPdev;


eval { JSON::PPdev->new->encode ([\-1]) }; ok $@ =~ /cannot encode reference/;
eval { JSON::PPdev->new->encode ([\undef]) }; ok $@ =~ /cannot encode reference/;
eval { JSON::PPdev->new->encode ([\2]) }; ok $@ =~ /cannot encode reference/;
eval { JSON::PPdev->new->encode ([\{}]) }; ok $@ =~ /cannot encode reference/;
eval { JSON::PPdev->new->encode ([\[]]) }; ok $@ =~ /cannot encode reference/;
eval { JSON::PPdev->new->encode ([\\1]) }; ok $@ =~ /cannot encode reference/;
eval { JSON::PPdev->new->allow_nonref (1)->decode ('"\u1234\udc00"') }; ok $@ =~ /missing high /;
eval { JSON::PPdev->new->allow_nonref->decode ('"\ud800"') }; ok $@ =~ /missing low /;
eval { JSON::PPdev->new->allow_nonref (1)->decode ('"\ud800\u1234"') }; ok $@ =~ /surrogate pair /;
eval { JSON::PPdev->new->decode ('null') }; ok $@ =~ /allow_nonref/;
eval { JSON::PPdev->new->allow_nonref (1)->decode ('+0') }; ok $@ =~ /malformed/;
eval { JSON::PPdev->new->allow_nonref->decode ('.2') }; ok $@ =~ /malformed/;
eval { JSON::PPdev->new->allow_nonref (1)->decode ('bare') }; ok $@ =~ /malformed/;
eval { JSON::PPdev->new->allow_nonref->decode ('naughty') }; ok $@ =~ /null/;
eval { JSON::PPdev->new->allow_nonref (1)->decode ('01') }; ok $@ =~ /leading zero/;
eval { JSON::PPdev->new->allow_nonref->decode ('00') }; ok $@ =~ /leading zero/;
eval { JSON::PPdev->new->allow_nonref (1)->decode ('-0.') }; ok $@ =~ /decimal point/;
eval { JSON::PPdev->new->allow_nonref->decode ('-0e') }; ok $@ =~ /exp sign/;
eval { JSON::PPdev->new->allow_nonref (1)->decode ('-e+1') }; ok $@ =~ /initial minus/;
eval { JSON::PPdev->new->allow_nonref->decode ("\"\n\"") }; ok $@ =~ /invalid character/;
eval { JSON::PPdev->new->allow_nonref (1)->decode ("\"\x01\"") }; ok $@ =~ /invalid character/;
eval { JSON::PPdev->new->decode ('[5') }; ok $@ =~ /parsing array/;
eval { JSON::PPdev->new->decode ('{"5"') }; ok $@ =~ /':' expected/;
eval { JSON::PPdev->new->decode ('{"5":null') }; ok $@ =~ /parsing object/;

eval { JSON::PPdev->new->decode (undef) }; ok $@ =~ /malformed/;
eval { JSON::PPdev->new->decode (\5) }; ok !!$@; # Can't coerce readonly
eval { JSON::PPdev->new->decode ([]) }; ok $@ =~ /malformed/;
eval { JSON::PPdev->new->decode (\*STDERR) }; ok $@ =~ /malformed/;
eval { JSON::PPdev->new->decode (*STDERR) }; ok !!$@; # cannot coerce GLOB

eval { decode_json ("\"\xa0") }; ok $@ =~ /malformed.*character/;
eval { decode_json ("\"\xa0\"") }; ok $@ =~ /malformed.*character/;

