package FusionInventory::Agent::Tools::Hardware::Nortel;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Agent::Tools::Network;

sub setTrunkPorts {
    my (%params) = @_;

    my $snmp  = $params{snmp};
    my $model = $params{model};
    my $ports = $params{ports};

    my $results = $snmp->walk($model->{oids}->{PortVlanIndex});

    my $myports;

    while (my ($oid, $vlan) = sort each %{$results}) {
        $myports->{getElement($oid, -2)}->{getElement($oid, -1)} = $vlan;
    }

    while (my ($portnumber, $vlans) = sort each %{$myports}) {
        if (keys %{$vlans} == 1) {
            # a single vlan
            while (my ($id, $name) = sort each %{$vlans}) {
                $ports->{$ports->{$portnumber}}->{VLANS}->{VLAN}->[0] = {
                    NAME   => $name,
                    NUMBER => $id
                };
            }
        } else {
            # trunk
            $ports->{$ports->{$portnumber}}->{TRUNK} = 1;
        }
    }
}

sub setConnectedDevices {
    my (%params) = @_;

    my $snmp  = $params{snmp};
    my $model = $params{model};
    my $ports = $params{ports};

    my $lldpRemChassisId = $snmp->walk($model->{oids}->{lldpRemChassisId});

    while (my ($oid, $chassisname) = sort each %{$lldpRemChassisId}) {
        my $suffix = $oid;

        my $connections =
            $ports->{getElement($suffix, 2)}->{CONNECTIONS};

        $connections->{CONNECTION}->{IFNUMBER} = getElement($suffix, 3);
        $connections->{CONNECTION}->{SYSMAC} =
            alt2canonical($chassisname);
        $connections->{CDP} = 1;
    }
}

1;
=head1 NAME

FusionInventory::Agent::Tools::Hardware::Nortel - Nortel-specific functions

=head1 DESCRIPTION

This is a class defining some functions specific to Nortel hardware.

=head1 FUNCTIONS

=head2 setTrunkPorts(%params)

Set trunk bit on relevant ports.

=over

=item results raw values collected through SNMP

=item ports device ports list

=back

=head2 setConnectedDevices(%params)

Set connected devices, through CDP or LLDP.

=over

=item results raw values collected through SNMP

=item ports device ports list

=item model model

=back
