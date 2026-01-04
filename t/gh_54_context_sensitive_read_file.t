use strict;
use warnings;
use Test::More;

BEGIN { plan tests => 1 };

BEGIN { $ENV{PERL_JSON_BACKEND} = 0; }

use JSON::PP;

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
