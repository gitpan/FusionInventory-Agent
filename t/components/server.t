#!/usr/bin/perl

use strict;
use warnings;
use lib 't';

use Config;
use English qw(-no_match_vars);
use LWP::UserAgent;
use Socket;
use Test::More;
use Test::Exception;
use UNIVERSAL::require;

use FusionInventory::Test::Agent;
use FusionInventory::Agent::Logger;

# check thread support availability
if ($Config{usethreads} ne 'define') {
    plan skip_all => 'non working test without thread support';
} else {
    FusionInventory::Agent::HTTP::Server->use();
    plan tests => 7;
}

my $logger = FusionInventory::Agent::Logger->new(
    backends => [ 'Test' ]
);

my $scheduler = FusionInventory::Agent::Scheduler->new(
);

my $server;

lives_ok {
    $server = FusionInventory::Agent::HTTP::Server->new(
        agent     => FusionInventory::Test::Agent->new(),
        scheduler => $scheduler,
        logger    => $logger,
        htmldir   => 'share/html'
    );
} 'instanciation with default values: ok';

my $client = LWP::UserAgent->new(timeout => 2);

ok(
    $client->get('http://localhost:62354')->is_success(),
    'server listening on default port'
);

$server->terminate();

lives_ok {
    $server = FusionInventory::Agent::HTTP::Server->new(
        agent     => FusionInventory::Test::Agent->new(),
        scheduler => $scheduler,
        logger    => $logger,
        port      => 8080,
        htmldir   => 'share/html'
    );
} 'instanciation with specific port: ok';
sleep 1;

ok(
    !$client->get('http://localhost:62354')->is_success(),
    'server not listening anymore on default port'
);

ok(
    $client->get('http://localhost:8080')->is_success(),
    'server listening on specific port'
);

# fork a child process, as when running in server mode
if (my $pid = fork()) {
    # parent
    waitpid($pid, 0);
} else {
    # child
    exit(0);
}

ok(
    $client->get('http://localhost:8080')->is_success(),
    'server still listening after child process exit'
);

# fork a child process, and raise ALRM from it, as when a timeout is reached
if (my $pid = fork()) {
    # parent
    waitpid($pid, 0);
} else {
    # child
    alarm 1;
    exit(0);
}

ok(
    $client->get('http://localhost:8080')->is_success(),
    'server still listening after child process raised ALRM'
);


$server->terminate();
