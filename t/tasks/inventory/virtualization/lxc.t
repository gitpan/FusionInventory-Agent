#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Agent::Task::Inventory::Virtualization::Lxc;

my $result_lxc_info = {
    STATUS => 'running',
    VMID   => '13018'
};

my $result_config = {
    MEMORY => '2048000',
    MAC    => '01:23:45:67:89:0A',
    VCPU   => 4
};

plan tests => 3;

my $state = FusionInventory::Agent::Task::Inventory::Virtualization::Lxc::_getVirtualMachineState(
    file => 'resources/virtualization/lxc/lxc-info_-n_name1'
);
cmp_deeply($state, $result_lxc_info, "lxc-info -n name1 -1");

my $config = FusionInventory::Agent::Task::Inventory::Virtualization::Lxc::_getVirtualMachineConfig(
    file => 'resources/virtualization/lxc/config'
);
cmp_deeply($config, $result_config, "parsing lxc config sample");
