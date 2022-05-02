use strict;
no warnings;
use Test::More;
BEGIN { plan tests => 19 * (6 + 2) + 1 * (12 + 2) };

BEGIN { $ENV{PERL_JSON_BACKEND} = 0; }

use JSON::PP;

################################################################
###  Warning: Some inputs may get stuck in an infinite loop  ###
###      so we're going to run each test under `Test::Fork`  ###
################################################################

use Test::Fork;
sub run_test {
    my ($num_tests, $input, $sub) = @_;
    my $pid = fork_ok($num_tests => sub {
        setpgrp 0, 0;
        $sub->($input);
    });

    local $SIG{ALRM} = sub { warn "\e[31mnot ok - '$input' hung; killing $pid...\e[m\n"; kill -9, $pid };
    alarm 10;
    waitpid $pid, 0;
    alarm 0;
}

#################################################################

# Try 'JSON::XS' and 'JSON::PP'...
for my $JSON_LIB (qw< JSON::XS JSON::PP >) {
    unless ( eval "use ${JSON_LIB}(); 1" ) {
        diag "$JSON_LIB not found; skipping...";
        next;
    }

    run_test(3, '{"one": 1}', sub {
        my $input = shift;
        my $coder = $JSON_LIB->new;
        my $res = eval { $coder->incr_parse($input) };
        my $e = $@; # test more clobbers $@, we need it twice
        ok ($res, "$JSON_LIB: curly braces okay -- '$input'");
        ok (!$e, "$JSON_LIB: no error -- '$input'");
        unlike ($e, qr/, or \} expected while parsing object\/hash/, "$JSON_LIB: No '} expected' json string error");
    });

    run_test(3, '{"one": 1]', sub {
        my $input = shift;
        my $coder = $JSON_LIB->new;
        my $res = eval { $coder->incr_parse($input) };
        my $e = $@; # test more clobbers $@, we need it twice
        ok (!$res, "$JSON_LIB: unbalanced curly braces -- '$input'");
        ok ($e, "$JSON_LIB: got error -- '$input'");
        like ($e, qr/, or \} expected while parsing object\/hash/, "$JSON_LIB: '} expected' json string error");
    });

    run_test(3, '"', sub {
        my $input = shift;
        my $coder = $JSON_LIB->new;
        my $res = eval { $coder->incr_parse($input) };
        my $e = $@; # test more clobbers $@, we need it twice
        ok (!$res, "$JSON_LIB: truncated input='$input'");
        ok (!$e, "$JSON_LIB: no error for input='$input'");
        unlike ($e, qr/, or \} expected while parsing object\/hash/, "$JSON_LIB: No '} expected' json string error for input='$input'");
    });

    run_test(3, '{', sub {
        my $input = shift;
        my $coder = $JSON_LIB->new;
        my $res = eval { $coder->incr_parse($input) };
        my $e = $@; # test more clobbers $@, we need it twice
        ok (!$res, "$JSON_LIB: truncated input='$input'");
        ok (!$e, "$JSON_LIB: no error for input='$input'");
        unlike ($e, qr/, or \} expected while parsing object\/hash/, "$JSON_LIB: No '} expected' json string error for input='$input'");
    });

    run_test(3, '[', sub {
        my $input = shift;
        my $coder = $JSON_LIB->new;
        my $res = eval { $coder->incr_parse($input) };
        my $e = $@; # test more clobbers $@, we need it twice
        ok (!$res, "$JSON_LIB: truncated input='$input'");
        ok (!$e, "$JSON_LIB: no error for input='$input'");
        unlike ($e, qr/, or \} expected while parsing object\/hash/, "$JSON_LIB: No '} expected' json string error for input='$input'");
    });

    run_test(3, '}', sub {
        my $input = shift;
        my $coder = $JSON_LIB->new;
        my $res = eval { $coder->incr_parse($input) };
        my $e = $@; # test more clobbers $@, we need it twice
        ok (!$res, "$JSON_LIB: truncated input='$input'");
        ok ($e, "$JSON_LIB: no error for input='$input'");
        like ($e, qr/malformed JSON string/, "$JSON_LIB: 'malformed JSON string' json string error for input='$input'");
    });

    run_test(3, ']', sub {
        my $input = shift;
        my $coder = $JSON_LIB->new;
        my $res = eval { $coder->incr_parse($input) };
        my $e = $@; # test more clobbers $@, we need it twice
        ok (!$res, "$JSON_LIB: truncated input='$input'");
        ok ($e, "$JSON_LIB: no error for input='$input'");
        like ($e, qr/malformed JSON string/, "$JSON_LIB: 'malformed JSON string' json string error for input='$input'");
    });

    run_test(3, '1', sub {
        my $input = shift;
        my $coder = $JSON_LIB->new;
        my $res = eval { $coder->incr_parse($input) };
        my $e = $@; # test more clobbers $@, we need it twice
        ok ($res, "$JSON_LIB: truncated input='$input'");
        ok (!$e, "$JSON_LIB: no error for input='$input'");
        unlike ($e, qr/malformed JSON string/, "$JSON_LIB: 'malformed JSON string' json string error for input='$input'");
    });

    run_test(3, '1', sub {
        my $input = shift;
        my $coder = $JSON_LIB->new->allow_nonref(0);
        my $res = eval { $coder->incr_parse($input) };
        my $e = $@; # test more clobbers $@, we need it twice
        ok (!$res, "$JSON_LIB: truncated input='$input'");
        ok ($e, "$JSON_LIB: no error for input='$input'");
        like ($e, qr/JSON text must be an object or array/, "$JSON_LIB: 'JSON text must be an object or array' json string error for input='$input'");
    });

    run_test(3, '"1', sub {
        my $input = shift;
        my $coder = $JSON_LIB->new;
        my $res = eval { $coder->incr_parse($input) };
        my $e = $@; # test more clobbers $@, we need it twice
        ok (!$res, "$JSON_LIB: truncated input='$input'");
        ok (!$e, "$JSON_LIB: no error for input='$input'");
        unlike ($e, qr/malformed JSON string/, "$JSON_LIB: 'malformed JSON string' json string error for input='$input'");
    });

    run_test(3, '\\', sub {
        my $input = shift;
        my $coder = $JSON_LIB->new;
        my $res = eval { $coder->incr_parse($input) };
        my $e = $@; # test more clobbers $@, we need it twice
        ok (!$res, "$JSON_LIB: truncated input='$input'");
        ok ($e, "$JSON_LIB: no error for input='$input'");
        like ($e, qr/malformed JSON string/, "$JSON_LIB: 'malformed JSON string' json string error for input='$input'");
    });

    run_test(3, '{"one": "', sub {
        my $input = shift;
        my $coder = $JSON_LIB->new;
        my $res = eval { $coder->incr_parse($input) };
        my $e = $@; # test more clobbers $@, we need it twice
        ok (!$res, "$JSON_LIB: truncated input='$input'");
        ok (!$e, "$JSON_LIB: no error for input='$input'");
        unlike ($e, qr/, or \} expected while parsing object\/hash/, "$JSON_LIB: No '} expected' json string error for input='$input'");
    });

    run_test(3, '{"one": {', sub {
        my $input = shift;
        my $coder = $JSON_LIB->new;
        my $res = eval { $coder->incr_parse($input) };
        my $e = $@; # test more clobbers $@, we need it twice
        ok (!$res, "$JSON_LIB: truncated input='$input'");
        ok (!$e, "$JSON_LIB: no error for input='$input'");
        unlike ($e, qr/, or \} expected while parsing object\/hash/, "$JSON_LIB: No '} expected' json string error for input='$input'");
    });

    run_test(3, '{"one": [', sub {
        my $input = shift;
        my $coder = $JSON_LIB->new;
        my $res = eval { $coder->incr_parse($input) };
        my $e = $@; # test more clobbers $@, we need it twice
        ok (!$res, "$JSON_LIB: truncated input='$input'");
        ok (!$e, "$JSON_LIB: no error for input='$input'");
        unlike ($e, qr/, or \} expected while parsing object\/hash/, "$JSON_LIB: No '} expected' json string error for input='$input'");
    });

    run_test(3, '{"one": t', sub {
        my $input = shift;
        my $coder = $JSON_LIB->new;
        my $res = eval { $coder->incr_parse($input) };
        my $e = $@; # test more clobbers $@, we need it twice
        ok (!$res, "$JSON_LIB: truncated input='$input'");
        ok (!$e, "$JSON_LIB: no error for input='$input'");
        unlike ($e, qr/, or \} expected while parsing object\/hash/, "$JSON_LIB: No '} expected' json string error for input='$input'");
    });

    run_test(3, '{"one": \\', sub {
        my $input = shift;
        my $coder = $JSON_LIB->new;
        my $res = eval { $coder->incr_parse($input) };
        my $e = $@; # test more clobbers $@, we need it twice
        ok (!$res, "$JSON_LIB: truncated input='$input'");
        ok (!$e, "$JSON_LIB: no error for input='$input'");
        unlike ($e, qr/, or \} expected while parsing object\/hash/, "$JSON_LIB: No '} expected' json string error for input='$input'");
    });

    run_test(3, '{"one": ', sub {
        my $input = shift;
        my $coder = $JSON_LIB->new;
        my $res = eval { $coder->incr_parse($input) };
        my $e = $@; # test more clobbers $@, we need it twice
        ok (!$res, "$JSON_LIB: truncated input='$input'");
        ok (!$e, "$JSON_LIB: no error for input='$input'");
        unlike ($e, qr/, or \} expected while parsing object\/hash/, "$JSON_LIB: No '} expected' json string error for input='$input'");
    });

    run_test(3, '{"one": 1', sub {
        my $input = shift;
        my $coder = $JSON_LIB->new;
        my $res = eval { $coder->incr_parse($input) };
        my $e = $@; # test more clobbers $@, we need it twice
        ok (!$res, "$JSON_LIB: truncated input='$input'");
        ok (!$e, "$JSON_LIB: no error for input='$input'");
        unlike ($e, qr/, or \} expected while parsing object\/hash/, "$JSON_LIB: No '} expected' json string error for input='$input'");
    });

    run_test(3, '{"one": {"two": 2', sub {
        my $input = shift;
        my $coder = $JSON_LIB->new;
        my $res = eval { $coder->incr_parse($input) };
        my $e = $@; # test more clobbers $@, we need it twice
        ok (!$res, "$JSON_LIB: truncated '$input'");
        ok (!$e, "$JSON_LIB: no error -- '$input'");
        unlike ($e, qr/, or \} expected while parsing object\/hash/, "$JSON_LIB: No '} expected' json string error -- $input");
    });

    # Test Appending Closing '}' Curly Bracket
    run_test(6, '{"one": 1', sub {
        my $input = shift;
        my $coder = $JSON_LIB->new;
        {
          my $res = eval { $coder->incr_parse($input) };
          my $e = $@; # test more clobbers $@, we need it twice
          ok (!$res, "$JSON_LIB: truncated input='$input'");
          ok (!$e, "$JSON_LIB: no error for input='$input'");
          unlike ($e, qr/, or \} expected while parsing object\/hash/, "$JSON_LIB: No '} expected' json string error for input='$input'");

          $res = eval { $coder->incr_parse('}') };
          $e = $@; # test more clobbers $@, we need it twice
          ok ($res, "$JSON_LIB: truncated input='$input' . '}'");
          ok (!$e, "$JSON_LIB: no error for input='$input' . '}'");
          unlike ($e, qr/, or \} expected while parsing object\/hash/, "$JSON_LIB: No '} expected' json string error for input='$input' . '}'");
        }
    });
}
