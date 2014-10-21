#!/usr/bin/perl

use strict;
use warnings;
use lib 't';

use English qw(-no_match_vars);
use Test::More;
use Test::Exception;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::HTTP::Client;
use FusionInventory::Test::Server;
use FusionInventory::Test::Utils;

# check than 'localhost' resolves, to an IPv4 address only
my $localhost_ok = test_localhost();

if (!$localhost_ok) {
    plan skip_all => 'non working test without pure IPv4 localhost';
} elsif ($OSNAME eq 'MSWin32') {
    plan skip_all => 'non working test on Windows';
} elsif ($OSNAME eq 'darwin') {
    plan skip_all => 'non working test on MacOS';
} else {
    plan tests => 8;
}

my $ok = sub {
    my ($server, $cgi) = @_;

    print "HTTP/1.0 200 OK\r\n";
    print "\r\n";
    print "OK";
};

my $logger = FusionInventory::Agent::Logger->new(
    backends => [ 'Test' ]
);

# no connection tests
BAIL_OUT("port aleady used") if test_port(8080);

my $server;
my $url = 'https://localhost:8080/public';
my $unsafe_client = FusionInventory::Agent::HTTP::Client->new(
    logger       => $logger,
    no_ssl_check => 1,
);
my $secure_client = FusionInventory::Agent::HTTP::Client->new(
    logger       => $logger,
    ca_cert_file => 't/ssl/crt/ca.pem',
);

my $secure_sha256_client = FusionInventory::Agent::HTTP::Client->new(
    logger       => $logger,
    ca_cert_file => 't/ssl/crt/ca.pem',
);

# ensure the server get stopped even if an exception is thrown
$SIG{__DIE__}  = sub { $server->stop(); };

# trusted certificate, correct hostname
$server = FusionInventory::Test::Server->new(
    port     => 8080,
    user     => 'test',
    realm    => 'test',
    password => 'test',
    ssl      => 1,
    crt      => 't/ssl/crt/good.pem',
    key      => 't/ssl/key/good.pem',
);
$server->set_dispatch({
    '/public'  => $ok,
});
$server->background();

ok(
    $secure_client->request(HTTP::Request->new(GET => $url))->is_success(),
    'trusted certificate, correct hostname: connection success'
);

$server->stop();

# trusted sha256 certificate, correct hostname
$server = FusionInventory::Test::Server->new(
    port     => 8080,
    user     => 'test',
    realm    => 'test',
    password => 'test',
    ssl      => 1,
    crt      => 't/ssl/crt/good-sha256.pem',
    key      => 't/ssl/key/good-sha256.pem',
);
$server->set_dispatch({
    '/public'  => $ok,
});
$server->background();

ok(
    $secure_sha256_client->request(HTTP::Request->new(GET => $url))->is_success(),
    'trusted certificate (sha256), correct hostname: connection success'
);

$server->stop();

# trusted certificate, alternate hostname
$server = FusionInventory::Test::Server->new(
    port     => 8080,
    user     => 'test',
    realm    => 'test',
    password => 'test',
    ssl      => 1,
    crt      => 't/ssl/crt/alternate.pem',
    key      => 't/ssl/key/alternate.pem',
);
$server->set_dispatch({
    '/public'  => $ok,
});
$server->background();


SKIP: {
skip "LWP version too old, skipping", 1 unless $LWP::VERSION >= 6;
ok(
    $secure_client->request(HTTP::Request->new(GET => $url))->is_success(),
    'trusted certificate, alternate hostname: connection success'
);
}

$server->stop();

# trusted certificate, joker
SKIP: {
    skip 'unable to resolve localhost.localdomain', 1
        unless gethostbyname('localhost.localdomain');

    $server = FusionInventory::Test::Server->new(
        port     => 8080,
        user     => 'test',
        realm    => 'test',
        password => 'test',
        ssl      => 1,
        crt      => 't/ssl/crt/joker.pem',
        key      => 't/ssl/key/joker.pem',
    );
    $server->set_dispatch({
        '/public'  => $ok,
    });
    $server->background();

    ok(
        $secure_client->request(
            HTTP::Request->new(GET => 'https://localhost.localdomain:8080/public')
        )->is_success(),
        'trusted certificate, joker: connection success'
    );

    $server->stop();
}

# trusted certificate, wrong hostname
$server = FusionInventory::Test::Server->new(
    port     => 8080,
    user     => 'test',
    realm    => 'test',
    password => 'test',
    ssl      => 1,
    crt      => 't/ssl/crt/wrong.pem',
    key      => 't/ssl/key/wrong.pem',
);
$server->set_dispatch({
    '/public'  => $ok,
});
$server->background();

ok(
    !$secure_client->request(HTTP::Request->new(GET => $url))->is_success(),
    'trusted certificate, wrong hostname: connection failure'
);

ok(
    $unsafe_client->request(HTTP::Request->new(GET => $url))->is_success(),
    'trusted certificate, wrong hostname, no check: connection success'
);

$server->stop();

# untrusted certificate, correct hostname
$server = FusionInventory::Test::Server->new(
    port     => 8080,
    user     => 'test',
    realm    => 'test',
    password => 'test',
    ssl      => 1,
    crt      => 't/ssl/crt/bad.pem',
    key      => 't/ssl/key/bad.pem',
);
$server->set_dispatch({
    '/public'  => $ok,
});
$server->background();

ok(
    !$secure_client->request(HTTP::Request->new(GET => $url))->is_success(),
    'untrusted certificate, correct hostname: connection failure'
);

SKIP: {
skip "LWP version too old, skipping", 1 unless $LWP::VERSION >= 6;
ok(
    $unsafe_client->request(HTTP::Request->new(GET => $url))->is_success(),
    'untrusted certificate, correct hostname, no check: connection success'
);
}

$server->stop();
