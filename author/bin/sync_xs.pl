# This script is to copy tests from JSON::XS and modify

use strict;
use warnings;
use FindBin;
use Path::Tiny;

my $root = path("$FindBin::Bin/../..");
my $xs_root = $root->parent->child('JSON-XS');
my $test_dir = $root->child('t');

die "JSON-XS directory not found" unless -d $xs_root;

for my $xs_test ($xs_root->child('t')->children) {
    my $basename = $xs_test->basename;
    $basename =~ s/^([0-9][0-9])/0$1/;
    my $pp_test = $test_dir->child($basename);
    if ($basename =~ /\.t$/) {
        my $content = $xs_test->slurp;

        # common stuff
        $content =~ s/(\015\012|\015|\012)/\n/gs;
        $content =~ s/JSON::XS/JSON::PP/g;
        $content =~ s/new JSON::PP/JSON::PP->new/g;
        $content =~ s/Types::Serialiser/JSON::PP/g;
        $content =~ s/use JSON::PP;\nuse JSON::PP;\n/use JSON::PP;\n/g;
        $content =~ s/our \$test;\nsub ok\(\$(;\$)?\) \{\n   print \$_\[0\] \? "" : "not ", "ok ", \+\+\$test, ".*?\\n";\n}\n//s;
        $content =~ s/#! perl\n\n//s;
        $content =~ s/BEGIN \{ \$\| = 1; print "1..(\d+)\\n"; }\n/use strict;\nuse Test::More;\nBEGIN { plan tests => $1 };\n/s unless $basename =~ /000_load/;
        $content =~ s/\$xs/\$pp/g;

        $content =~ s/((?:use utf8;\n)?use JSON::PP;\n)/BEGIN { \$ENV{PERL_JSON_BACKEND} = 0; }\n\n$1/s;

        $content =~ s/(# copied over from JSON::PC and modified to use JSON::PP\n)/$1# copied over from JSON::XS and modified to use JSON::PP\n/s or $content =~ s/\A/# copied over from JSON::XS and modified to use JSON::PP\n\n/s;

        if ($content !~ /use strict;\n(?:use|no) warnings/) {
            $content =~ s/(use strict;\n)/$1use warnings;\n/;
        }

        # specific
        if ($basename =~ /000_load/) {
            $content =~ s/(# copied over from JSON::XS and modified to use JSON::PP\n\n)/$1use strict;\nuse warnings;\n\nmy \$loaded;\n/;
        }

        if ($basename =~ /001_utf8/) {
            $content =~ s/(use JSON::PP;\n\n).+/$1/s;
            $content .=<< 'TEST';
my $pilcrow_utf8 = (ord "^" == 0x5E) ? "\xc2\xb6"  # 8859-1
                 : (ord "^" == 0x5F) ? "\x80\x65"  # CP 1024
                 :                     "\x78\x64"; # assume CP 037
is (JSON::PP->new->allow_nonref (1)->utf8 (1)->encode ("¶"), "\"$pilcrow_utf8\"");
is (JSON::PP->new->allow_nonref (1)->encode ("¶"), "\"¶\"");
is (JSON::PP->new->allow_nonref (1)->ascii (1)->utf8 (1)->encode (chr 0x8000), '"\u8000"');
is (JSON::PP->new->allow_nonref (1)->ascii (1)->utf8 (1)->pretty (1)->encode (chr 0x10402), "\"\\ud801\\udc02\"\n");

eval { JSON::PP->new->allow_nonref (1)->utf8 (1)->decode ('"¶"') };
ok $@ =~ /malformed UTF-8/;

is (JSON::PP->new->allow_nonref (1)->decode ('"¶"'), "¶");
is (JSON::PP->new->allow_nonref (1)->decode ('"\u00b6"'), "¶");
is (JSON::PP->new->allow_nonref (1)->decode ('"\ud801\udc02' . "\x{10204}\""), "\x{10402}\x{10204}");

my $controls = (ord "^" == 0x5E) ? "\012\\\015\011\014\010"
             : (ord "^" == 0x5F) ? "\025\\\015\005\014\026"  # CP 1024
             :                     "\045\\\015\005\014\026"; # assume CP 037
is (JSON::PP->new->allow_nonref (1)->decode ('"\"\n\\\\\r\t\f\b"'), "\"$controls");

TEST
        }

        if ($basename =~ /002_error/) {
            $content =~ s!(eval \{ decode_json \("1\\x01"\) }; ok \$\@ =~ /garbage after/;)!{ #SKIP_UNLESS_XS4_COMPAT 4\n$1!;
            $content =~ s!(eval \{ decode_json \("\[\]\\x00"\) }; ok \$\@ =~ /garbage after/;)!$1\n}!;
        }
        if ($basename =~ /003_types/) {
            $content =~ s/for \$v /for my \$v /;
            $content =~ s/BEGIN \{ plan tests => (\d+) };\n/BEGIN \{ plan tests => $1 + 2 };\n/;
            $content =~ s/(ok \(!JSON::PP::is_bool \$false\);\n)/$1ok \(!JSON::PP::is_bool "JSON::PP::Boolean"\);\nok \(!JSON::PP::is_bool \{}\); # GH-34\n/s;
        }

        if ($basename =~ /004_dwiw_encode/) {
            $content =~ s!use Test;!use Test::More tests => 5;!;
            $content =~ s!BEGIN \{ plan tests => 5 \}\s+BEGIN!BEGIN!s;
        }

        if ($basename =~ /005_dwiw_decode/) {
            $content =~ s!use Test;!use Test::More tests => 7;!;
            $content =~ s!BEGIN \{ plan tests => 7 \}\s+BEGIN!BEGIN!s;
        }

        if ($basename =~ /008_pc_base/) {
            $content =~ s!'\["\\\\u001b"\]'! \(ord\("A"\) == 65\) \? '\["\\\\u001b"\]' : '\["\\\\u0027"\]'!;
        }

        if ($basename =~ /011_pc_expo/) {
            $content =~ s/BEGIN \{ plan tests => (\d+) };\n/BEGIN \{ plan tests => $1 + 2 };\n/;
            $content =~ s/(\$js = \$pc->encode\(\$obj\);\nis\(\$js,'\[\-123400\]', 'digit -1.234e5'\);\n)/{ #SKIP_IF_CPANEL\n$1}\n/;
            $content =~ s!like\(\$js,qr/\\\[1\.01\[Ee\]\\\+0\?30\\\]/, 'digit 1\.01e\+30'\);\n!like(\$js,qr/\\[(?:1\.01\[Ee\]\\+0\?30|1010000000000000000000000000000\)\]/, 'digit 1.01e+30'); # RT-128589 (-Duselongdouble or -Dquadmath) \n!;

            $content .= <<'END';
my $vax_float = (pack("d",1) =~ /^[\x80\x10]\x40/);

if ($vax_float) {
    # VAX has smaller float range.
    $js  = q|[1.01e+37]|;
    $obj = $pc->decode($js);
    is($obj->[0], eval '1.01e+37', 'digit 1.01e+37');
    $js = $pc->encode($obj);
    like($js,qr/\[1.01[Ee]\+0?37\]/, 'digit 1.01e+37');
} else {
    $js  = q|[1.01e+67]|; # 30 -> 67 ... patched by H.Merijn Brand
    $obj = $pc->decode($js);
    is($obj->[0], eval '1.01e+67', 'digit 1.01e+67');
    $js = $pc->encode($obj);
    like($js,qr/\[1.01[Ee]\+0?67\]/, 'digit 1.01e+67');
}
END

        }

        if ($basename =~ /012_blessed/) {
            $content =~ s/\{__,""}/{'__',""}/;
            $content =~ s/\$js\->filter_json_single_key_object \(a => sub \{ }\);/\$js\->filter_json_single_key_object \(a => sub \{ return; }\); # sub {} is not suitable for Perl 5.6/;
        }

        if ($basename =~ /013_limit/) {
            $content =~ s/(my \$js = JSON::PP->new;\n)/$1local \$^W; # to silence Deep recursion warnings\n/;
        }

        if ($basename =~ /014_latin1/) {
            $content =~ s/print (.+?)\s+\?.*\\n";/ok ($1);/g;
            $content =~ s!\\x\{89\}!\\x\{b6\}!g;
        }

        if ($basename =~ /015_prefix/) {
            $content =~ s/print \$\@ \? "not " : "", .*\\n";/ok (!\$\@);/g;
            $content =~ s/print (.+?)\s+\?.*\\n";/ok ($1);/g;
        }

        if ($basename =~ /018_json_checker/) {
            $content =~ s/(binmode DATA;\n)/my \$vax_float = (pack("d",1) =~ \/^[\\x80\\x10]\\x40\/);\n\n$1/s;
            $content =~ s/(   my \$name = <DATA>;\n)/$1   if (\$vax_float && \$name =~ \/pass1.json\/) {\n       \$test =~ s\/\\b23456789012E66\\b\/23456789012E20\/;\n   }\n/s;
        }

        if ($basename =~ /019_incr/) {
            $content =~ s!(splitter \+JSON::PP->new\s+, ' 0\.00E\+00 ';)!{ #SKIP_UNLESS_PP 3, 33\n$1\n}!;
        }

        if ($basename =~ /020_faihu/) {
            $content =~ s|(use JSON::PP;)|BEGIN { if (\$\] < 5.008) { require Test::More; Test::More::plan(skip_all => "requires Perl 5.8 or later"); } };\n\n$1|;
        }

        if ($basename =~ /022_comment_at_eof/) {
            $content =~ s/# (provided by IKEGAMI\@cpan.org)/# the original test case was $1/;
        }

        if ($basename =~ /052_object/) {
            my %seen;
            $content =~ s/\$(json|obj|enc|dec) = /(!$seen{$1}++ ? "my " : "" ) . "\$$1 = "/ge;
            $content =~ s/print (.+?)\s+\?.*\\n";/ok ($1);/g;
            $content =~ s/print "ok \d+\\n";/ok (1);/g;
            $content =~ s/(use strict;)/package JSON::PP::freeze;\n\n1;\n\npackage JSON::PP::tojson;\n\n1;\n\npackage main;\n\n$1/;
        }

        if ($basename =~ /099_binary/) {
            $content =~ s/(, )([0-9])(\);)/$1" - $2"$3/g;
        }


        $pp_test->spew($content);
        print STDERR "copied $xs_test to $pp_test\n";
        next;
    }
    print STDERR "Skipped $xs_test\n";
}
