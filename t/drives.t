#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::Linux::Drives;
use Test::More;
use FindBin;

my %hal_tests = (
    'dell-xt2' => [
        {
            VOLUMN => '/dev/',
            TOTAL  => 44814
        },
        {
            VOLUMN     => '/dev/sda7',
            TOTAL      => 44814,
            SERIAL     => 'f75b1fa9-1109-46b4-abde-541af44ed8cd',
            FILESYSTEM => 'crypto_LUKS'
        },
        {
            VOLUMN     => '/dev/sda6',
            TOTAL      => 3993,
            SERIAL     => '3aebfe11-8dba-4c61-87b1-10f391dba4fc',
            LABEL      => 'swap',
            FILESYSTEM => 'swap'
        },
        {
            VOLUMN => '/dev/sda4',
            TOTAL  => 0
        },
        {
            VOLUMN     => '/dev/sda5',
            TOTAL      => 12300,
            SERIAL     => '7a20e641-ec5f-41ff-8c7b-2056b18cae80',
            LABEL      => 'root',
            FILESYSTEM => 'ext4'
        },
        {
            VOLUMN     => '/dev/sda3',
            TOTAL      => 60003,
            SERIAL     => '5A60194E6019326D',
            LABEL      => 'OS',
            FILESYSTEM => 'ntfs-3g'
        },
        {
            VOLUMN     => '/dev/sda2',
            TOTAL      => 750,
            SERIAL     => 'CCE616B2E6169CB0',
            LABEL      => 'RECOVERY',
            FILESYSTEM => 'ntfs-3g'
        },
        {
            VOLUMN     => '/dev/sda1',
            TOTAL      => 243,
            SERIAL     => '07DA-0305',
            LABEL      => 'DellUtility',
            FILESYSTEM => 'vfat'
        }
    ]
);

plan tests => scalar keys %hal_tests;

foreach my $test (keys %hal_tests) {
    my $file = "$FindBin::Bin/../resources/hal/$test";
    my $results = FusionInventory::Agent::Task::Inventory::OS::Linux::Drives::parseLshal($file, '<');
    is_deeply($hal_tests{$test}, $results, $test);
}
