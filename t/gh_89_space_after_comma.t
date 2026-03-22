use strict;
use warnings;
use Test::More;

use JSON::PP;

#SKIP_ALL_UNLESS_PP 4.18

my $got = JSON::PP->new->utf8->space_after(1)->encode({x=>[1,2]});
is $got => qq!{"x": [1, 2]}!, "has a space after 1";

done_testing;
