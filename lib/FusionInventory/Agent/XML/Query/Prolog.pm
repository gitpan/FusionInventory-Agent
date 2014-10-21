package FusionInventory::Agent::XML::Query::Prolog;

use strict;
use warnings;
use base 'FusionInventory::Agent::XML::Query';

sub new {
    my ($class, %params) = @_;

    die "no token parameter" unless $params{token};

    return $class->SUPER::new(
        query => 'PROLOG',
        %params
    );

}

1;
__END__

=head1 NAME

FusionInventory::Agent::XML::Query::Prolog - Prolog agent message

=head1 DESCRIPTION

This is an initial message sent by the agent to the server before any task is
processed, requiring execution parameters.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, in addition to those
from the base class C<FusionInventory::Agent::XML::Query>, as keys of the
%params hash:

=over

=item I<token>

the authentication token for the web interface (mandatory)

=back
