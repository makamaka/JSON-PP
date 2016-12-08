package JSON::PP::Spec;

use strict;
use warnings;

use base 'Exporter';
our @EXPORT = our @EXPORT_OK = qw(anyof arrayof hashof);

sub anyof {
    my $has_hash;
    my $has_array;
    my $has_scalar;
    foreach ( @_ ) {
        my $type = ref($_);
        if ( $type ne '' ) {
            if ( $type eq 'HASH' or $type eq 'JSON::PP::Spec::HashOf' ) {
                die 'Only one hash type can be specified in anyof' if $has_hash;
                $has_hash = 1;
            } elsif ( $type eq 'ARRAY' or $type eq 'JSON::PP::Spec::ArrayOf' ) {
                die 'Only one array type can be specified in anyof' if $has_array;
                $has_array = 1;
            } else {
                die 'Only scalar, array or hash can be specified in anyof';
            }
        } elsif ( $_ ne 'NULL' ) {
            die 'Only one scalar type can be specified in anyof' if $has_scalar;
            $has_scalar = 1;
        }
    }
    return bless \@_, 'JSON::PP::Spec::AnyOf';
}

sub arrayof {
    die 'Exactly one type must be specified in arrayof' if scalar @_ != 1;
    return bless \$_[0], 'JSON::PP::Spec::ArrayOf';
}

sub hashof {
    die 'Exactly one type must be specified in hashof' if scalar @_ != 1;
    return bless \$_[0], 'JSON::PP::Spec::HashOf';
}

1;
