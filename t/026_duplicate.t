# copied over from JSON::XS and modified to use JSON::PP

use Test::More;
use strict;

BEGIN { plan tests => 4 };

BEGIN { $ENV{PERL_JSON_BACKEND} = 0; }

BEGIN {
    use lib qw(t);
    use _unicode_handling;
}

use utf8;
use JSON::PP;


my $json = JSON::PP->new;

is (encode_json $json->decode ('{"a":"b","a":"c"}'), '{"a":"c"}'); # t/test_parsing/y_object_duplicated_key.json
is (encode_json $json->decode ('{"a":"b","a":"b"}'), '{"a":"b"}'); # t/test_parsing/y_object_duplicated_key_and_value.json

$json->disallow_dupkeys;
ok (!eval { $json->decode ('{"a":"b","a":"c"}') }); # t/test_parsing/y_object_duplicated_key.json
ok (!eval { $json->decode ('{"a":"b","a":"b"}') }); # t/test_parsing/y_object_duplicated_key_and_value.json
