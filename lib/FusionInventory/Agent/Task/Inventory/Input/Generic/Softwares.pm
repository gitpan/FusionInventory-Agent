package FusionInventory::Agent::Task::Inventory::Input::Generic::Softwares;

use strict;
use warnings;

sub isEnabled {
    my (%params) = @_;

    return !$params{no_category}->{software};
}

sub doInventory {}

1;
