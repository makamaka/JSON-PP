# copied over from JSON::XS and modified to use JSON::PP

use strict;
use warnings;

use Test::More;
plan tests => 1;

use JSON::PP;

my $source = qq<"\xff\xc3\xa9\\u00e9">;

my $dec = JSON::PP->new()->utf8( JSON::PP::UTF8_BYTES );

is(
    $dec->decode($source),
    "\xff\xc3\xa9\xc3\xa9",
    "utf8(UTF8_BYTES): expected decode",
);
