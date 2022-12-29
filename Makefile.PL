require 5.008;
use strict;
use ExtUtils::MakeMaker;

use lib qw( ./lib );

# ensure old versions installed from bundled copy in ExtUtils::MakeMaker
# are removed when installing this; this will warn on old EU::MM but
# still works
my $needs_uninst = $] < 5.012
    && ! $ENV{PERL_NO_HIGHLANDER}
    && ! ( $ENV{PERL_MM_OPT} && $ENV{PERL_MM_OPT} =~ /(?:INSTALL_BASE|PREFIX)/ )
    && ! grep { /INSTALL_BASE/ || /PREFIX/ } @ARGV;

WriteMakefile(
    'NAME'          => 'JSON::PP',
    'VERSION_FROM'  => 'lib/JSON/PP.pm', # finds $VERSION
    'PREREQ_PM'     => {
              'Test::More'  => 0,
              'Scalar::Util' => '1.08'
    },
    'EXE_FILES' => [ 'bin/json_pp' ],
    'ABSTRACT_FROM' => 'lib/JSON/PP.pm', # retrieve abstract from module
    'AUTHOR'        => 'Makamaka Hannyaharamitu, E<lt>makamaka[at]cpan.orgE<gt>',
    ( $ExtUtils::MakeMaker::VERSION >= 6.3002 ? ('LICENSE' => 'perl', ) : () ),

    ( $ExtUtils::MakeMaker::VERSION >= 6.46 ? (
        'META_MERGE' => {
            resources => {
                repository  =>  'https://github.com/makamaka/JSON-PP',
                bugtracker  =>  'https://github.com/makamaka/JSON-PP/issues',
            },
        } ) : ()
    ),
    ( $needs_uninst ? ( UNINST => 1 ) : () ),
);
