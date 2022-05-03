use strict;
no warnings;
use Test::More;
BEGIN { plan tests => 19 * 3 + 1 * 6 };

BEGIN { $ENV{PERL_JSON_BACKEND} = 0; }

use JSON::PP;

sub run_test {
    my ($num_tests, $input, $sub) = @_;
    $sub->($input);
}

#################################################################

unless ( eval "use JSON::PP(); 1" ) {
    diag "JSON::PP not found; skipping...";
    next;
}

run_test(3, '{"one": 1}', sub {
    my $input = shift;
    my $coder = JSON::PP->new;
    my $res = eval { $coder->incr_parse($input) };
    my $e = $@; # test more clobbers $@, we need it twice
    ok ($res, "curly braces okay -- '$input'");
    ok (!$e, "no error -- '$input'");
    unlike ($e, qr/, or \} expected while parsing object\/hash/, "No '} expected' json string error");
});

run_test(3, '{"one": 1]', sub {
    my $input = shift;
    my $coder = JSON::PP->new;
    my $res = eval { $coder->incr_parse($input) };
    my $e = $@; # test more clobbers $@, we need it twice
    ok (!$res, "unbalanced curly braces -- '$input'");
    ok ($e, "got error -- '$input'");
    like ($e, qr/, or \} expected while parsing object\/hash/, "'} expected' json string error");
});

run_test(3, '"', sub {
    my $input = shift;
    my $coder = JSON::PP->new;
    my $res = eval { $coder->incr_parse($input) };
    my $e = $@; # test more clobbers $@, we need it twice
    ok (!$res, "truncated input='$input'");
    ok (!$e, "no error for input='$input'");
    unlike ($e, qr/, or \} expected while parsing object\/hash/, "No '} expected' json string error for input='$input'");
});

run_test(3, '{', sub {
    my $input = shift;
    my $coder = JSON::PP->new;
    my $res = eval { $coder->incr_parse($input) };
    my $e = $@; # test more clobbers $@, we need it twice
    ok (!$res, "truncated input='$input'");
    ok (!$e, "no error for input='$input'");
    unlike ($e, qr/, or \} expected while parsing object\/hash/, "No '} expected' json string error for input='$input'");
});

run_test(3, '[', sub {
    my $input = shift;
    my $coder = JSON::PP->new;
    my $res = eval { $coder->incr_parse($input) };
    my $e = $@; # test more clobbers $@, we need it twice
    ok (!$res, "truncated input='$input'");
    ok (!$e, "no error for input='$input'");
    unlike ($e, qr/, or \} expected while parsing object\/hash/, "No '} expected' json string error for input='$input'");
});

run_test(3, '}', sub {
    my $input = shift;
    my $coder = JSON::PP->new;
    my $res = eval { $coder->incr_parse($input) };
    my $e = $@; # test more clobbers $@, we need it twice
    ok (!$res, "truncated input='$input'");
    ok ($e, "no error for input='$input'");
    like ($e, qr/malformed JSON string/, "'malformed JSON string' json string error for input='$input'");
});

run_test(3, ']', sub {
    my $input = shift;
    my $coder = JSON::PP->new;
    my $res = eval { $coder->incr_parse($input) };
    my $e = $@; # test more clobbers $@, we need it twice
    ok (!$res, "truncated input='$input'");
    ok ($e, "no error for input='$input'");
    like ($e, qr/malformed JSON string/, "'malformed JSON string' json string error for input='$input'");
});

run_test(3, '1', sub {
    my $input = shift;
    my $coder = JSON::PP->new;
    my $res = eval { $coder->incr_parse($input) };
    my $e = $@; # test more clobbers $@, we need it twice
    ok ($res, "truncated input='$input'");
    ok (!$e, "no error for input='$input'");
    unlike ($e, qr/malformed JSON string/, "'malformed JSON string' json string error for input='$input'");
});

run_test(3, '1', sub {
    my $input = shift;
    my $coder = JSON::PP->new->allow_nonref(0);
    my $res = eval { $coder->incr_parse($input) };
    my $e = $@; # test more clobbers $@, we need it twice
    ok (!$res, "truncated input='$input'");
    ok ($e, "no error for input='$input'");
    like ($e, qr/JSON text must be an object or array/, "'JSON text must be an object or array' json string error for input='$input'");
});

run_test(3, '"1', sub {
    my $input = shift;
    my $coder = JSON::PP->new;
    my $res = eval { $coder->incr_parse($input) };
    my $e = $@; # test more clobbers $@, we need it twice
    ok (!$res, "truncated input='$input'");
    ok (!$e, "no error for input='$input'");
    unlike ($e, qr/malformed JSON string/, "'malformed JSON string' json string error for input='$input'");
});

run_test(3, '\\', sub {
    my $input = shift;
    my $coder = JSON::PP->new;
    my $res = eval { $coder->incr_parse($input) };
    my $e = $@; # test more clobbers $@, we need it twice
    ok (!$res, "truncated input='$input'");
    ok ($e, "no error for input='$input'");
    like ($e, qr/malformed JSON string/, "'malformed JSON string' json string error for input='$input'");
});

run_test(3, '{"one": "', sub {
    my $input = shift;
    my $coder = JSON::PP->new;
    my $res = eval { $coder->incr_parse($input) };
    my $e = $@; # test more clobbers $@, we need it twice
    ok (!$res, "truncated input='$input'");
    ok (!$e, "no error for input='$input'");
    unlike ($e, qr/, or \} expected while parsing object\/hash/, "No '} expected' json string error for input='$input'");
});

run_test(3, '{"one": {', sub {
    my $input = shift;
    my $coder = JSON::PP->new;
    my $res = eval { $coder->incr_parse($input) };
    my $e = $@; # test more clobbers $@, we need it twice
    ok (!$res, "truncated input='$input'");
    ok (!$e, "no error for input='$input'");
    unlike ($e, qr/, or \} expected while parsing object\/hash/, "No '} expected' json string error for input='$input'");
});

run_test(3, '{"one": [', sub {
    my $input = shift;
    my $coder = JSON::PP->new;
    my $res = eval { $coder->incr_parse($input) };
    my $e = $@; # test more clobbers $@, we need it twice
    ok (!$res, "truncated input='$input'");
    ok (!$e, "no error for input='$input'");
    unlike ($e, qr/, or \} expected while parsing object\/hash/, "No '} expected' json string error for input='$input'");
});

run_test(3, '{"one": t', sub {
    my $input = shift;
    my $coder = JSON::PP->new;
    my $res = eval { $coder->incr_parse($input) };
    my $e = $@; # test more clobbers $@, we need it twice
    ok (!$res, "truncated input='$input'");
    ok (!$e, "no error for input='$input'");
    unlike ($e, qr/, or \} expected while parsing object\/hash/, "No '} expected' json string error for input='$input'");
});

run_test(3, '{"one": \\', sub {
    my $input = shift;
    my $coder = JSON::PP->new;
    my $res = eval { $coder->incr_parse($input) };
    my $e = $@; # test more clobbers $@, we need it twice
    ok (!$res, "truncated input='$input'");
    ok (!$e, "no error for input='$input'");
    unlike ($e, qr/, or \} expected while parsing object\/hash/, "No '} expected' json string error for input='$input'");
});

run_test(3, '{"one": ', sub {
    my $input = shift;
    my $coder = JSON::PP->new;
    my $res = eval { $coder->incr_parse($input) };
    my $e = $@; # test more clobbers $@, we need it twice
    ok (!$res, "truncated input='$input'");
    ok (!$e, "no error for input='$input'");
    unlike ($e, qr/, or \} expected while parsing object\/hash/, "No '} expected' json string error for input='$input'");
});

run_test(3, '{"one": 1', sub {
    my $input = shift;
    my $coder = JSON::PP->new;
    my $res = eval { $coder->incr_parse($input) };
    my $e = $@; # test more clobbers $@, we need it twice
    ok (!$res, "truncated input='$input'");
    ok (!$e, "no error for input='$input'");
    unlike ($e, qr/, or \} expected while parsing object\/hash/, "No '} expected' json string error for input='$input'");
});

run_test(3, '{"one": {"two": 2', sub {
    my $input = shift;
    my $coder = JSON::PP->new;
    my $res = eval { $coder->incr_parse($input) };
    my $e = $@; # test more clobbers $@, we need it twice
    ok (!$res, "truncated '$input'");
    ok (!$e, "no error -- '$input'");
    unlike ($e, qr/, or \} expected while parsing object\/hash/, "No '} expected' json string error -- $input");
});

# Test Appending Closing '}' Curly Bracket
run_test(6, '{"one": 1', sub {
    my $input = shift;
    my $coder = JSON::PP->new;
    {
      my $res = eval { $coder->incr_parse($input) };
      my $e = $@; # test more clobbers $@, we need it twice
      ok (!$res, "truncated input='$input'");
      ok (!$e, "no error for input='$input'");
      unlike ($e, qr/, or \} expected while parsing object\/hash/, "No '} expected' json string error for input='$input'");

      $res = eval { $coder->incr_parse('}') };
      $e = $@; # test more clobbers $@, we need it twice
      ok ($res, "truncated input='$input' . '}'");
      ok (!$e, "no error for input='$input' . '}'");
      unlike ($e, qr/, or \} expected while parsing object\/hash/, "No '} expected' json string error for input='$input' . '}'");
    }
});
