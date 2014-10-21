#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Temp;
use IPC::Run qw(run);
use XML::TreePP;

use FusionInventory::Agent::Tools;

use Test::More tests => 27;

my ($out, $err, $rc);

($out, $err, $rc) = run_agent('--help');
ok($rc == 2, '--help exit status');
like(
    $err,
    qr/^Usage:/,
    '--help stderr'
);
is($out, '', '--help stdin');

($out, $err, $rc) = run_agent('--version');
ok($rc == 0, '--version exit status');
is($err, '', '--version stderr');
like(
    $out,
    qr/^FusionInventory unified agent for UNIX, Linux and MacOSX/,
    '--version stdin'
);


($out, $err, $rc) = run_agent();
ok($rc == 1, 'no target exit status');
like(
    $err,
    qr/No target defined/,
    'no target stderr'
);
is($out, '', 'no target stdin');

my $base_options = "--stdout --debug --no-task ocsdeploy,wakeonlan,snmpquery,netdiscovery";

my $content;

# first inventory
($out, $err, $rc) = run_agent(
    "$base_options --no-category printer"
);

subtest "first inventory" => sub {
    check_execution_ok($out, $err, $rc);
};

ok(
    exists $content->{REQUEST}->{CONTENT}->{SOFTWARES},
    'inventory has software'
);

ok(
    exists $content->{REQUEST}->{CONTENT}->{ENVS},
    'inventory has environment variables'
);

# second inventory, without software
($out, $err, $rc) = run_agent(
    "$base_options --no-category printer,software"
);

subtest "first inventory" => sub {
    check_execution_ok($out, $err, $rc);
};

ok(
    !exists $content->{REQUEST}->{CONTENT}->{SOFTWARES},
    "output doesn't have any software"
);

ok(
    exists $content->{REQUEST}->{CONTENT}->{ENVS},
    'inventory has environment variables'
);

# third inventory, without software, but additional content

my $file = File::Temp->new(UNLINK => $ENV{TEST_DEBUG} ? 0 : 1, SUFFIX => '.xml');
print $file <<EOF;
<?xml version="1.0" encoding="UTF-8" ?>
<REQUEST>
  <CONTENT>
      <SOFTWARES>
          <NAME>foo</NAME>
          <VERSION>bar</VERSION>
      </SOFTWARES>
  </CONTENT>
</REQUEST>
EOF
close($file);

($out, $err, $rc) = run_agent(
    "$base_options --no-category printer,software --additional-content $file"
);
subtest "first inventory" => sub {
    check_execution_ok($out, $err, $rc);
};

ok(
    exists $content->{REQUEST}->{CONTENT}->{SOFTWARES},
    'inventory has softwares'
);

ok(
    ref $content->{REQUEST}->{CONTENT}->{SOFTWARES} eq 'HASH',
    'inventory contains only one software'
);

ok(
    $content->{REQUEST}->{CONTENT}->{SOFTWARES}->{NAME} eq 'foo' &&
    $content->{REQUEST}->{CONTENT}->{SOFTWARES}->{VERSION} eq 'bar',
    'inventory contains the expected software'
);

ok(
    exists $content->{REQUEST}->{CONTENT}->{ENVS},
    'inventory has environment variables'
);

# PATH through WMI appears with %SystemRoot% templates, preventing direct
# comparaison with %ENV content
my $name = $OSNAME eq 'MSWin32' ? 'PATHEXT' : 'PATH';
my $value = $ENV{$name};

($out, $err, $rc) = run_agent(
    "$base_options --no-category printer,software"
);

subtest "first inventory" => sub {
    check_execution_ok($out, $err, $rc);
};

ok(
    !exists $content->{REQUEST}->{CONTENT}->{SOFTWARES},
    "inventory doesn't have any software"
);

ok(
    exists $content->{REQUEST}->{CONTENT}->{ENVS},
    'inventory has environment variables'
);

ok(
    (any
        { $_->{KEY} eq $name && $_->{VAL} eq $value } 
        @{$content->{REQUEST}->{CONTENT}->{ENVS}}
    ),
    'inventory has expected environment variable value'
);

($out, $err, $rc) = run_agent(
    "$base_options --no-category printer,software,environment"
);

subtest "first inventory" => sub {
    check_execution_ok($out, $err, $rc);
};

ok(
    !exists $content->{REQUEST}->{CONTENT}->{SOFTWARES},
    "inventory doesn't have any software"
);

ok(
    !exists $content->{REQUEST}->{CONTENT}->{ENVS},
    "inventory doesn't have any environment variables"
);

sub run_agent {
    my ($args) = @_;
    my @args = $args ? split(/\s+/, $args) : ();
    run(
        [ $EXECUTABLE_NAME, 'fusioninventory-agent', @args ],
        \my ($in, $out, $err)
    );
    return ($out, $err, $CHILD_ERROR >> 8);
}

sub check_execution_ok {
    my ($client, $url) = @_;

    ok($rc == 0, 'exit status');

    unlike(
        $err,
        qr/module \S+ disabled: failure to load/,
        'no broken module (loading)'
    );

    unlike(
        $err,
        qr/unexpected error in \S+/,
        'no broken module (execution)'
    );

    like(
        $out,
        qr/^<\?xml version="1.0" encoding="UTF-8" \?>/,
        'output has correct encoding'
    );

    $content = XML::TreePP->new()->parse($out);
    ok($content, 'output is valid XML');
}
