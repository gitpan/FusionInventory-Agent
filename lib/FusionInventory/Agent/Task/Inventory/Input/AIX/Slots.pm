package FusionInventory::Agent::Task::Inventory::Input::AIX::Slots;

use strict;
use warnings;

use List::Util qw(first);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::AIX;

sub isEnabled {
    return canRun('lsdev');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # index VPD infos by AX field
    my %infos =
        map  { $_->{AX} => $_ }
        grep { $_->{AX} }
        getLsvpdInfos(logger => $logger);  

    foreach my $slot (_getSlots(
        command => 'lsdev -Cc bus -F "name:description"',
        logger  => $logger
    )) {

        $slot->{DESCRIPTION} = $infos{$slot->{NAME}}->{YL}
            if $infos{$slot->{NAME}};

        $inventory->addEntry(
            section => 'SLOTS',
            entry   => $slot
        );
    }
}

sub _getSlots {
    my $handle = getFileHandle(@_);
    return unless $handle;


    my @slots;
    while (my $line = <$handle>) {
        next unless $line =~ /^(.+):(.+)/;

        push @slots, {
            NAME        => $1,
            DESIGNATION => $2,
            STATUS      => 'available'
        };
    }
    close $handle;

    return @slots;
}

1;
