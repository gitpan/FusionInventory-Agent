package FusionInventory::Agent::Task::Inventory::Input::Generic::Lspci;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return canRun('lspci');
}

sub doInventory {}

1;
