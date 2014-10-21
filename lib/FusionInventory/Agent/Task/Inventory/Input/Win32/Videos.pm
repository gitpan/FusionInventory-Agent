package FusionInventory::Agent::Task::Inventory::Input::Win32::Videos;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Win32;

my $seen;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    foreach my $object (getWmiObjects(
        class      => 'Win32_VideoController',
        properties => [ qw/
            CurrentHorizontalResolution CurrentVerticalResolution VideoProcessor
            AdaptaterRAM Name
        / ]
    )) {

        my $video = {
            CHIPSET => $object->{VideoProcessor},
            MEMORY  => $object->{AdaptaterRAM},
            NAME    => $object->{Name},
        };

        if ($object->{CurrentHorizontalResolution}) {
            $video->{RESOLUTION} =
                $object->{CurrentHorizontalResolution} .
                "x" .
                $object->{CurrentVerticalResolution};
        }

        $video->{MEMORY} = int($video->{MEMORY} / (1024 * 1024))
            if $video->{MEMORY};

        # avoid duplicates
        next if $seen->{$video->{NAME}}++;

        $inventory->addEntry(
            section => 'VIDEOS',
            entry   => $video
        );
    }
}

1;
