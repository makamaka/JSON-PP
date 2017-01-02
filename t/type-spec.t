use strict;
use Test::More;
BEGIN { plan tests => 74 };
BEGIN { $ENV{PERL_JSON_BACKEND} = 0 };
use JSON::PP;
use JSON::PP::Spec;

foreach my $false (JSON::PP::false, undef, 0, !!0, !1, "0", "", \0) {
    is(encode_json([$false], ['BOOL']), '[false]');
}

foreach my $true (JSON::PP::true, 1, !!1, !0, 2, 3, 100, -1, -100, "1", "2", "100", "-1", "-1", "true", "string", \1) {
    is(encode_json([$true], ['BOOL']), '[true]');
}

foreach my $zero (0, 0.0, "0") {
    is(encode_json([$zero], ['NULL']), '[null]');
    is(encode_json([$zero], ['BOOL']), '[false]');
    is(encode_json([$zero], ['INT']), '[0]');
    is(encode_json([$zero], ['FLOAT']), '[0.0]');
    is(encode_json([$zero], ['STRING']), '["0"]');
}

foreach my $ten (10, 10.0, "10") {
    is(encode_json([$ten], ['NULL']), '[null]');
    is(encode_json([$ten], ['BOOL']), '[true]');
    is(encode_json([$ten], ['INT']), '[10]');
    is(encode_json([$ten], ['FLOAT']), '[10.0]');
    is(encode_json([$ten], ['STRING']), '["10"]');
}

ok('[null]' eq encode_json [JSON::PP::false], ['NULL']);
ok('[false]' eq encode_json [JSON::PP::false], ['BOOL']);
ok('[0]' eq encode_json [JSON::PP::false], ['INT']);
ok('[0.0]' eq encode_json [JSON::PP::false], ['FLOAT']);
ok('["false"]' eq encode_json [JSON::PP::false], ['STRING']);
ok('[false]' eq encode_json [JSON::PP::false], ['SCALAR']);
ok('[false]' eq encode_json [JSON::PP::false], arrayof('SCALAR'));
ok('[false]' eq encode_json [JSON::PP::false], [anyof('SCALAR')]);

ok('[null]' eq encode_json [JSON::PP::true], ['NULL']);
ok('[true]' eq encode_json [JSON::PP::true], ['BOOL']);
ok('[1]' eq encode_json [JSON::PP::true], ['INT']);
ok('[1.0]' eq encode_json [JSON::PP::true], ['FLOAT']);
ok('["true"]' eq encode_json [JSON::PP::true], ['STRING']);
ok('[true]' eq encode_json [JSON::PP::true], ['SCALAR']);
ok('[true]' eq encode_json [JSON::PP::true], arrayof('SCALAR'));
ok('[true]' eq encode_json [JSON::PP::true], [anyof('SCALAR')]);

is(
    encode_json(
        [ { key1 => 'value1', key2 => 12 }, 1, [ 100, '101', JSON::PP::true ], undef ],
        arrayof(anyof('STRING', 'NULL', [ 'INT', 'INT', 'BOOL' ], hashof('STRING'))),
    ),
    '[{"key2":"12","key1":"value1"},"1",[100,101,true],null]',
);

is(
    encode_json(
        [ { key1 => '11', key2 => [ 12, 13 ] } ],
        [ { key1 => 'INT', key2 => [ 'STRING', 'INT' ] } ],
    ),
    '[{"key2":["12",13],"key1":11}]',
);

is(encode_json([["a"]], arrayof(anyof(arrayof(anyof({}, "STRING")), {}, "INT"))), '[["a"]]');
