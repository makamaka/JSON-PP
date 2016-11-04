use strict;
use Test::More;

BEGIN { plan tests => 1 };

BEGIN { $ENV{PERL_JSON_BACKEND} = 0; }

use JSON::PP;

eval { JSON::PP->new->decode('{}0') };
ok $@;
