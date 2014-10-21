#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use lib 't';

use English qw(-no_match_vars);
use Test::More;
use Test::MockModule;

use FusionInventory::Test::Utils;

BEGIN {
    # use mock modules for non-available ones
    push @INC, 't/fake/windows' if $OSNAME ne 'MSWin32';
}

use FusionInventory::Agent::Task::Inventory::Input::Win32::USB;

my %tests = (
    7 => [
        {
            NAME      => 'Generic USB Hub',
            VENDORID  => '8087',
            PRODUCTID => '0024'
        },
        {
            NAME      => 'Generic USB Hub',
            VENDORID  => '8087',
            PRODUCTID => '0024'
        },
        {
            NAME      => 'ASUS Bluetooth',
            VENDORID  => '0B05',
            PRODUCTID => '179C'
        },
        {
            NAME      => 'Périphérique USB composite',
            SERIAL    => '6BE882AB',
            VENDORID  => '046D',
            PRODUCTID => '08C9'
        },
        {
            NAME      => 'Périphérique d’entrée USB',
            VENDORID  => '046D',
            PRODUCTID => 'C03E'
        },
        {
            NAME      => 'Périphérique USB composite',
            VENDORID  => '046D',
            PRODUCTID => 'C30A'
        },
    ],
    xppro2 => [
        {
            NAME      => "Concentrador USB genérico",
            VENDORID  => '046A',
            PRODUCTID => '0009'
        },
        {
            NAME      => 'Dispositivo compuesto USB',
            VENDORID  => '046A',
            PRODUCTID => '0019'
        },
        {
            NAME      => 'SmartTerminal XX44',
            VENDORID  => '046A',
            PRODUCTID => '002D'
        },
        {
            NAME      => 'Compatibilidad con impresoras USB',
            SERIAL    => 'JV40VNJ',
            VENDORID  => '03F0',
            PRODUCTID => '3A17'
        },
        {
            NAME      => 'Compatibilidad con impresoras USB',
            SERIAL    => 'J5J126789',
            VENDORID  => '04F9',
            PRODUCTID => '002B'
        },
        {
            NAME      => 'Dispositivo compuesto USB',
            SERIAL    => '00CNBW86S20B',
            VENDORID  => '03F0',
            PRODUCTID => '3817'
        }
    ]
);

plan tests => scalar keys %tests;

my $module = Test::MockModule->new(
    'FusionInventory::Agent::Task::Inventory::Input::Win32::USB'
);

foreach my $test (keys %tests) {
    $module->mock(
        'getWmiObjects',
        mockGetWmiObjects($test)
    );

    my @devices = FusionInventory::Agent::Task::Inventory::Input::Win32::USB::_getUSBDevices();
    is_deeply(
        \@devices,
        $tests{$test},
        "$test sample"
    );
}
