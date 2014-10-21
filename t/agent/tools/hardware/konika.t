#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Test::Hardware;

my %tests = (
    'konica/bizhub_421.1.walk' => [
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            MAC          => '00:50:AA:27:95:9E',
            MODEL        => 'bizhub 421',
        },
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            MAC          => '00:50:AA:27:95:9E',
            MODEL        => 'bizhub 421',
        },
        {
            INFO => {
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => 'bizhub 421',
            },
        }
    ],
    'konica/bizhub_421.2.walk' => [
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            MAC          => '00:50:AA:27:96:68',
            MODEL        => 'bizhub 421',
        },
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            MAC          => '00:50:AA:27:96:68',
            MODEL        => 'bizhub 421',
        },
        {
            INFO => {
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => 'bizhub 421',
            },
        }
    ],
    'konica/bizhub_421.3.walk' => [
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            MAC          => '00:50:AA:27:95:A3',
            MODEL        => 'bizhub 421',
        },
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            MAC          => '00:50:AA:27:95:A3',
            MODEL        => 'bizhub 421',
        },
        {
            INFO => {
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => 'bizhub 421',
            },
        }
    ],
    'konica/bizhub_C224.1.walk' => [
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub C224e',
            MAC          => '00:20:6B:8A:DC:EC',
            MODEL        => 'bizhub C224',
        },
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub C224e',
            MAC          => '00:20:6B:8A:DC:EC',
            MODEL        => 'bizhub C224',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                MODEL        => 'bizhub C224',
            },
        }
    ],
);

setPlan(scalar keys %tests);

my $dictionary = getDictionnary();
my $index      = getIndex();

foreach my $test (sort keys %tests) {
    my $snmp  = getSNMP($test);
    my $model = getModel($index, $tests{$test}->[1]->{MODELSNMP});

    my %device0 = getDeviceInfo(
        snmp    => $snmp,
        datadir => './share'
    );
    cmp_deeply(\%device0, $tests{$test}->[0], "$test: base stage");

    my %device1 = getDeviceInfo(
        snmp       => $snmp,
        dictionary => $dictionary,
        datadir    => './share'
    );
    cmp_deeply(\%device1, $tests{$test}->[1], "$test: base + dictionnary stage");

    my $device3 = getDeviceFullInfo(
        snmp    => $snmp,
        model   => $model,
        datadir => './share'
    );
    cmp_deeply($device3, $tests{$test}->[2], "$test: base + model stage");
}
