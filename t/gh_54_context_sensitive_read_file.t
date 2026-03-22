use strict;
use warnings;
use Test::More;
use JSON::PP;

#SKIP_ALL_UNLESS_PP 4.18

BEGIN { plan tests => 1 };

my $ds = eval { JSON::PP::decode_json read_file() };
ok !$@, "No error" or note $@;

sub read_file {
	my $json = <<"JSON";
{
"camel": "Amelia"
}
JSON
	wantarray ? split(/\R/, $json) : $json;
}
