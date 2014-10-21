#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::MacOS::Videos;

my %tests = (

    '10.6.5-dual-monitor' => {
        MONITORS => [
            {
                DESCRIPTION => 'E2441',
                CAPTION     => 'E2441'
            },
            {
                DESCRIPTION => 'E2441_0',
                CAPTION     => 'E2441_0'
            }
        ],
        VIDEOS => [
            {
                NAME        => 'ATI Radeon HD 5770',
                RESOLUTION  => '1920x1080',
                CHIPSET     => 'ATI Radeon HD 5770',
                MEMORY      => '1024',
                PCISLOT     => 'Slot-1'
            },
            {
                NAME        => 'ATI Radeon HD 5770',
                RESOLUTION  => '1920x1080',
                CHIPSET     => 'ATI Radeon HD 5770',
                MEMORY      => '1024',
                PCISLOT     => 'Slot-1'
            }
        ]
    }
);

plan tests => scalar keys %tests;
use Data::Dumper;
foreach my $test (keys %tests) {
    my $file = "resources/macos/system_profiler/$test";
    my %displays = FusionInventory::Agent::Task::Inventory::Input::MacOS::Videos::_getDisplays(file => $file);
    is_deeply(\%displays, $tests{$test}, $test) or print Dumper(\%displays);
}
