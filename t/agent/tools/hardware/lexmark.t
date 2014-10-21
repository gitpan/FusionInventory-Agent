#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::More;
use Test::Deep qw(cmp_deeply);
use XML::TreePP;

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Task::NetDiscovery::Dictionary;
use FusionInventory::Agent::Tools::Hardware;

my %tests = (
    'lexmark/T622.walk' => [
        {
            MANUFACTURER => 'Lexmark',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Lexmark T622 version 54.30.06 kernel 2.4.0-test6 All-N-1',
            SNMPHOSTNAME => 'LXK3936A4',
            MAC          => '00:04:00:9c:6c:25',
        },
        {
            MANUFACTURER => 'Lexmark',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Lexmark T622 version 54.30.06 kernel 2.4.0-test6 All-N-1',
            SNMPHOSTNAME => 'LXK3936A4',
            MAC          => '00:04:00:9c:6c:25',
            MODELSNMP    => 'Printer0643',
            FIRMWARE     => undef,
            SERIAL       => 'LXK3936A4',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Lexmark',
                TYPE         => 'PRINTER',
                MODEL        => 'Lexmark T622 41XT225  543.006',
                COMMENTS     => 'Lexmark T622 version 54.30.06 kernel 2.4.0-test6 All-N-1',
                NAME         => 'LXK3936A4',
                MEMORY       => '32',
                IPS          => {
                    IP => [
                        '127.0.0.1',
                        '172.31.201.21',
                    ],
                },
                UPTIME       => '(256604241) 29 days, 16:47:22.41',
            },
            PAGECOUNTERS => {
                TOTAL      => '68116',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'lo0',
                        IFDESCR          => 'lo0',
                        IFTYPE           => '24',
                        IFSPEED          => '10000000',
                        IFMTU            => '3904',
                        IP               => '127.0.0.1',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '174',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '174',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'eth0',
                        IFDESCR          => 'eth0',
                        IFTYPE           => '6',
                        IFSPEED          => '10000000',
                        IFMTU            => '1500',
                        IP               => '172.31.201.21',
                        MAC              => '00:04:00:9c:6c:25',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '883395992',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '2404715',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Lexmark',
                TYPE         => 'PRINTER',
                MODEL        => 'Lexmark T622 41XT225  543.006',
                COMMENTS     => 'Lexmark T622 version 54.30.06 kernel 2.4.0-test6 All-N-1',
                NAME         => 'LXK3936A4',
                MEMORY       => '32',
                SERIAL       => 'LXK3936A4',
                IPS          => {
                    IP => [
                        '127.0.0.1',
                        '172.31.201.21',
                    ],
                },
                UPTIME       => '(256604241) 29 days, 16:47:22.41',
            },
            CARTRIDGES => {
                TONERBLACK       => '100',
            },
            PAGECOUNTERS => {
                TOTAL      => '68116',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'lo0',
                        IFDESCR          => 'lo0',
                        IFTYPE           => '24',
                        IFSPEED          => '10000000',
                        IFMTU            => '3904',
                        IP               => '127.0.0.1',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '174',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '174',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'eth0',
                        IFDESCR          => 'eth0',
                        IFTYPE           => '6',
                        IFSPEED          => '10000000',
                        IFMTU            => '1500',
                        IP               => '172.31.201.21',
                        MAC              => '00:04:00:9c:6c:25',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '883395992',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '2404715',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        },
    ],
    'lexmark/X792.walk' => [
        {
            MANUFACTURER => 'Lexmark',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Lexmark X792 version NH.HS2.N211La kernel 2.6.28.10.1 All-N-1',
            SNMPHOSTNAME => 'ET0021B7427721',
            MAC          => '00:21:b7:42:77:21',
            MODEL        => 'X792',
        },
        {
            MANUFACTURER => 'Lexmark',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Lexmark X792 version NH.HS2.N211La kernel 2.6.28.10.1 All-N-1',
            SNMPHOSTNAME => 'ET0021B7427721',
            MAC          => '00:21:b7:42:77:21',
            MODEL        => 'X792',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Lexmark',
                TYPE         => 'PRINTER',
                MODEL        => 'X792',
                COMMENTS     => 'Lexmark X792 version NH.HS2.N211La kernel 2.6.28.10.1 All-N-1',
                NAME         => 'ET0021B7427721',
            },
            CARTRIDGES => {
                TONERBLACK       => '90',
                TONERCYAN        => '90',
                TONERMAGENTA     => '90',
                TONERYELLOW      => '90',
            },
            PAGECOUNTERS => {
                TOTAL      => '25292',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'lo',
                        IFDESCR          => 'lo',
                        IFTYPE           => '24',
                        IFSPEED          => '10000000',
                        IFMTU            => '16436',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '526887060',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '526887060',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'eth0',
                        IFDESCR          => 'eth0',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        MAC              => '00:21:b7:42:77:21',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '436783447',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '51509126',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Lexmark',
                TYPE         => 'PRINTER',
                MODEL        => 'X792',
                COMMENTS     => 'Lexmark X792 version NH.HS2.N211La kernel 2.6.28.10.1 All-N-1',
                NAME         => 'ET0021B7427721',
            },
            CARTRIDGES => {
                TONERBLACK       => '90',
                TONERCYAN        => '90',
                TONERMAGENTA     => '90',
                TONERYELLOW      => '90',
            },
            PAGECOUNTERS => {
                TOTAL      => '25292',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'lo',
                        IFDESCR          => 'lo',
                        IFTYPE           => '24',
                        IFSPEED          => '10000000',
                        IFMTU            => '16436',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '526887060',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '526887060',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'eth0',
                        IFDESCR          => 'eth0',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        MAC              => '00:21:b7:42:77:21',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '436783447',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '51509126',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        },
    ],
);

plan skip_all => 'SNMP walks database required'
    if !$ENV{SNMPWALK_DATABASE};
plan tests => 4 * scalar keys %tests;

my ($dictionary, $index);
if ($ENV{SNMPMODELS_DICTIONARY}) {
    $dictionary = FusionInventory::Agent::Task::NetDiscovery::Dictionary->new(
        file => $ENV{SNMPMODELS_DICTIONARY}
    );
}
if ($ENV{SNMPMODELS_INDEX}) {
    $index = XML::TreePP->new()->parsefile($ENV{SNMPMODELS_INDEX});
}

foreach my $test (sort keys %tests) {
    my $snmp  = FusionInventory::Agent::SNMP::Mock->new(
        file => "$ENV{SNMPWALK_DATABASE}/$test"
    );

    # first test: discovery without dictionary
    my %device1 = getDeviceInfo(
        snmp    => $snmp,
        datadir => './share'
    );
    cmp_deeply(
        \%device1,
        $tests{$test}->[0],
        "$test: discovery, without dictionary"
    );

    # second test: discovery, with dictipnary
    SKIP: {
        skip "SNMP dictionary required, skipping", 1 unless $dictionary;

        my %device2 = getDeviceInfo(
            snmp       => $snmp,
            datadir    => './share',
            dictionary => $dictionary,
        );
        cmp_deeply(
            \%device2,
            $tests{$test}->[1],
            "$test: discovery, with dictionary"
        );
    };

    # third test: inventory without model
    my $device3 = getDeviceFullInfo(
        snmp    => $snmp,
        datadir => './share'
    );
    cmp_deeply(
        $device3,
        $tests{$test}->[2],
        "$test: inventory, without model"
    );

    # fourth test: inventory, with model
    SKIP: {
        my $model_id = $tests{$test}->[1]->{MODELSNMP};
        skip "SNMP models index required, skipping", 1 unless $index;
        skip "No model associated, skipping", 1 unless $model_id;
        my $model = loadModel($index->{$model_id});

        my $device4 = getDeviceFullInfo(
            snmp    => $snmp,
            datadir => './share',
            model   => $model
        );
        cmp_deeply(
            $device4,
            $tests{$test}->[3],
            "$test: inventory, with model"
        );
    };
}
