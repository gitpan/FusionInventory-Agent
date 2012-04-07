#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::AIX::Videos;

my %tests = (
    'aix-4.3.1' => [],
    'aix-4.3.2' => [],
    'aix-5.3a'  => [
        {
            NAME => 'lai0',
        }
    ],
    'aix-5.3b' => [],
    'aix-5.3c' => [],
    'aix-6.1a' => [],
    'aix-6.1b' => [
        {
            NAME => 'ati0',
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/aix/lsdev/$test-adapter";
    my @videos = FusionInventory::Agent::Task::Inventory::Input::AIX::Videos::_getVideos(file => $file);
    is_deeply(\@videos, $tests{$test}, "videos: $test");
}
