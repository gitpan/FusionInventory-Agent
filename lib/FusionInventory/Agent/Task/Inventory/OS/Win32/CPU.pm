package FusionInventory::Agent::Task::Inventory::OS::Win32::CPU;

use strict;
use warnings;

use constant KEY_WOW64_64KEY => 0x100;

use English qw(-no_match_vars);
use Win32::TieRegistry (
    Delimiter   => '/',
    ArrayValues => 0,
    qw/KEY_READ/
);

use FusionInventory::Agent::Task::Inventory::OS::Win32;

# the CPU description in WMI is false, we use the registry instead
# Hardware\Description\System\CentralProcessor\1
# thank you Nicolas Richard 
sub getCPUInfoFromRegistry {
    my ($logger, $cpuId) = @_;

    my $machKey= $Registry->Open('LMachine', {
        Access=> KEY_READ | KEY_WOW64_64KEY
    }) or $logger->fault("Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR");

    my $data =
        $machKey->{"Hardware/Description/System/CentralProcessor/".$cpuId};

    my $info;

    foreach my $tmpkey (%$data) {
        next unless $tmpkey =~ /^\/(.*)/;
        my $key = $1;

        $info->{$key} = $data->{$tmpkey};
    }

    return $info;
}



sub isInventoryEnabled {1}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    my $serial;
    my $speed;

    my $vmsystem;

    my @dmidecodeCpu;
    if (can_run("dmidecode")) {
        my $in;
        foreach (`dmidecode`) {
            if ($in && /^Handle/)  {
                push @dmidecodeCpu, {serial => $serial, speed => $speed};
                $in = 0;
            }

            if (/^Handle.*type 4,/) {
                $in = 1 
            } elsif ($in) {
                $speed = $1 if /Max Speed:\s+(\d+)\s+MHz/i;
                $speed = $1*1000 if /Max Speed:\s+(\w+)\s+GHz/i;
                $serial = $1 if /ID:\s+(.*)/i;
#                Core Count: 2
#                Core Enabled: 2
#                Thread Count: 2
            }
        }
    }



    my $cpuId = 0;
    foreach my $Properties (getWmiProperties('Win32_Processor', qw/
        NumberOfCores ProcessorId MaxClockSpeed
    /)) {

        my $info = getCPUInfoFromRegistry($logger, $cpuId);

#        my $cache = $Properties->{L2CacheSize}+$Properties->{L3CacheSize};
        my $core = $Properties->{NumberOfCores};
        my $description = $info->{Identifier};
        my $name = $info->{ProcessorNameString};
        my $manufacturer = $info->{VendorIdentifier};
        my $serial = $dmidecodeCpu[$cpuId]->{serial} || $Properties->{ProcessorId};
        my $speed = $dmidecodeCpu[$cpuId]->{speed} || $Properties->{MaxClockSpeed};

        if ($manufacturer) {
            $manufacturer =~ s/Genuine//;
            $manufacturer =~ s/(TMx86|TransmetaCPU)/Transmeta/;
            $manufacturer =~ s/CyrixInstead/Cyrix/;
            $manufacturer=~ s/CentaurHauls/VIA/;
        }
        if ($serial) {
            $serial =~ s/\s//g;
        }

        if ($name) {
            $name =~ s/^\s+//;
            $name =~ s/\s+$//;
        }

        $vmsystem = "QEMU"if $name =~ /QEMU/i;

        if ($name =~ /([\d\.]+)s*(GHZ)/i) {
            $speed = {
               ghz => 1000,
               mhz => 1,
            }->{lc($2)}*$1;
        }



        $inventory->addCPU({
#           CACHE => $cache,
            CORE => $core,
            DESCRIPTION => $description,
            NAME => $name,
            MANUFACTURER => $manufacturer,
            SERIAL => $serial,
            SPEED => $speed
        });

        $cpuId++;
    }

    if ($vmsystem) {
        $inventory->setHardware ({
            VMSYSTEM => $vmsystem 
        });
    }




}
1;
