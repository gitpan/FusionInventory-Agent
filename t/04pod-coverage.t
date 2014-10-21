#!/usr/bin/perl

use strict;
use warnings;
use lib 't';

use Test::More;
use English qw(-no_match_vars);

plan(skip_all => 'Author test, set $ENV{TEST_AUTHOR} to a true value to run')
    if !$ENV{TEST_AUTHOR};

eval { require Test::Pod::Coverage; };
plan(skip_all => 'Test::Pod::Coverage required') if $EVAL_ERROR;

Test::Pod::Coverage->import();
if ($OSNAME eq 'MSWin32') {
    push @INC, 't/fake/unix';
} else {
    push @INC, 't/fake/windows';
}

my @modules = grep { filter($_) } all_modules('lib');
plan tests => scalar @modules;
foreach my $module (@modules) {
    pod_coverage_ok(
        $module,
        {
            coverage_class => 'Pod::Coverage::CountParents',
            also_private => [ qw/doInventory isEnabled/ ],
        }
    );
}

# namespace-based filter
sub filter {
    return 0 if $_ =~ m{FusionInventory::VMware};
    return 1 if $_ =~ m{FusionInventory::Agent::Task::(Inventory|WakeOnLan)};
    return 0 if $_ =~ m{FusionInventory::Agent::Task};
    return 1;
}
