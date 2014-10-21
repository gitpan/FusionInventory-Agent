package FusionInventory::Agent::Task::Inventory::Input::Solaris::Drives;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

sub isEnabled {
    return canRun('df');
}

sub _getDfCmd {
    my $line = getFirstLine(
        command => "df --version"
    );

# df --help is on STDERR on some system
# so $line is undef
    return ($line && $line =~ /GNU/) ?
        "df -P -k" :
        "df -k";
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # get filesystems list
    my @filesystems =
        # exclude solaris 10 specific devices
        grep { $_->{VOLUMN} !~ /^\/(devices|platform)/ } 
        # exclude cdrom mount
        grep { $_->{TYPE} !~ /cdrom/ } 
        # get all file systems
        getFilesystemsFromDf(logger => $logger, command => _getDfCmd());

    # get additional informations
    foreach my $filesystem (@filesystems) {

        if ($filesystem->{VOLUMN} eq 'swap') {
            $filesystem->{FILESYSTEM} = 'swap';
            next;
        }

        # use -H to exclude headers
        my $zfs_line = getFirstLine(
            command => "zfs get -H creation $filesystem->{VOLUMN}"
        );
        if ($zfs_line && $zfs_line =~ /creation\s+(\S.*\S+)\s*-/) {
            $filesystem->{FILESYSTEM} = 'zfs';
            next;
        }

        # call fstype, and set filesystem type unless the output matches
        # erroneous result
        my $fstyp_line = getFirstLine(command => "fstyp $filesystem->{VOLUMN}");
        if ($fstyp_line && $fstyp_line !~ /^fstyp/) {
            $filesystem->{FILESYSTEM} = $fstyp_line;
        }
    }

    # add filesystems to the inventory
    foreach my $filesystem (@filesystems) {
        $inventory->addEntry(
            section => 'DRIVES',
            entry   => $filesystem
        );
    }
}
1;
