use strict;
use warnings;
use Test::More;

BEGIN { $ENV{PERL_JSON_BACKEND} = 0; }

my @candidates = qw(JSON::PP JSON::XS Cpanel::JSON::XS);

for my $json_module (@candidates) {
    eval "require $json_module; 1" or next;
    my $got = $json_module->new->utf8->space_after(1)->encode({x=>[1,2]});
    is $got => qq!{"x": [1, 2]}!, "$json_module has a space after 1";
}

done_testing;
