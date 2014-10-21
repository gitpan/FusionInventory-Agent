#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::AIX::Sounds;

my %tests = (
    'aix-4.3.1' => [],
    'aix-4.3.2' => [],
    'aix-5.3a'  => [],
    'aix-5.3b'  => [],
    'aix-5.3c'  => [],
    'aix-6.1a'  => [],
    'aix-6.1b'  => [],
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/aix/lsdev/$test-adapter";
    my @sounds = FusionInventory::Agent::Task::Inventory::Input::AIX::Sounds::_getSounds(file => $file);
    is_deeply(\@sounds, $tests{$test}, "sounds: $test");
}
