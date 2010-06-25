package FusionInventory::Agent::Task::Inventory::OS::BSD::CPU;

use strict;
use warnings;

sub isInventoryEnabled {
    return unless -r "/dev/mem";

    `which dmidecode 2>&1`;
    return if ($? >> 8)!=0;
    `dmidecode 2>&1`;
    return if ($? >> 8)!=0;
    1;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $processort;
    my $processorn;
    my $processors;

    my $family;
    my $manufacturer;

# XXX Parsing dmidecode output using "type 4" section
# for nproc type and speed
# because no /proc on *BSD
    my $flag=0;
    my $status=0; ### XXX 0 if Unpopulated
    chomp($processorn = `sysctl -n hw.ncpu`);
    chomp($processort = `sysctl -n hw.model`);
    for(`dmidecode`){

        $status = 1 if $flag && /^\s*status\s*:.*enabled/i;
        $processors = $1 if $flag && /^\s*current speed\s*:\s*(\d+).+/i;
    }

    $inventory->setHardware({
        PROCESSORT => $processort,
        PROCESSORN => $processorn,
        PROCESSORS => $processors
    });

}
1;
