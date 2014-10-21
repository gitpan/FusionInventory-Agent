#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Test::Hardware;

my %tests = (
    'tandberg/codec.walk' => [
        {
            MANUFACTURER => 'Tandberg',
            DESCRIPTION  => 'TANDBERG Codec',
            SNMPHOSTNAME => 'VISIO.1',
            MAC          => '00:50:60:02:9B:79',
        },
        {
            MANUFACTURER => 'Tandberg',
            DESCRIPTION  => 'TANDBERG Codec',
            SNMPHOSTNAME => 'VISIO.1',
            MAC          => '00:50:60:02:9B:79',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Tandberg',
                TYPE         => undef,
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
        snmp       => $snmp,
        datadir    => './share'
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
