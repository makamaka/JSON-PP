=head1 NAME

JSON::PPdev::Boolean - dummy module providing JSON::PP::Boolean

=head1 SYNOPSIS

 # do not "use" yourself

=head1 DESCRIPTION

This module exists only to provide overload resolution for Storable and similar modules. See
L<JSON::PPdev> for more info about this class.

=cut

use JSON::PP ();
use strict;

1;

=head1 AUTHOR

This idea is from L<JSON::XS::Boolean> written by Marc Lehmann <schmorp[at]schmorp.de>

=cut

