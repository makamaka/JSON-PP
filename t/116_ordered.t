use strict;
use Test::More;

use JSON::PP;

# from https://rt.cpan.org/Ticket/Display.html?id=25162

SKIP: {
    eval { require Tie::StoredOrderHash };
    skip "Can't load Tie::StoredOrderHash.", 2 if ($@);

    my $json = JSON::PP->new->object_constructor(sub { Tie::StoredOrderHash->new });

    my $js = $json->decode('{"id":"int","1":"a","2":"b","3":"c","4":"d","5":"e"}');
    my @keys = keys %$js;
    is join(' ', @keys), 'id 1 2 3 4 5', 'Ordered';

}


done_testing();

