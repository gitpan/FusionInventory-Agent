package FusionInventory::Agent::Config;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Spec;
use Getopt::Long;
use UNIVERSAL::require;

my $default = {
    'additional-content'      => undef,
    'backend-collect-timeout' => 180,
    'ca-cert-dir'             => undef,
    'ca-cert-file'            => undef,
    'color'                   => undef,
    'debug'                   => undef,
    'delaytime'               => 3600,
    'force'                   => undef,
    'html'                    => undef,
    'lazy'                    => undef,
    'local'                   => undef,
    'logger'                  => 'Stderr',
    'logfile'                 => undef,
    'logfacility'             => 'LOG_USER',
    'logfile-maxsize'         => undef,
    'no-category'             => [],
    'no-httpd'                => undef,
    'no-ssl-check'            => undef,
    'no-task'                 => [],
    'no-p2p'                  => undef,
    'password'                => undef,
    'proxy'                   => undef,
    'httpd-ip'                => undef,
    'httpd-port'              => 62354,
    'httpd-trust'             => [],
    'scan-homedirs'           => undef,
    'server'                  => undef,
    'tag'                     => undef,
    'timeout'                 => 180,
    'user'                    => undef,
    # deprecated options
    'stdout'                  => undef,
    # multi-values options that will be converted to array ref
    'httpd-trust'             => "",
    'no-task'                 => "",
    'no-category'             => ""
};

my $deprecated = {
    'stdout' => {
        message => 'use --local - option instead',
        new     => { 'local' => '-' }
    },
};

sub new {
    my ($class, %params) = @_;

    my $self = {};
    bless $self, $class;
    $self->_loadDefaults();
    my $backend =
        $params{options}->{'conf-file'} ? 'file'                     :
        $params{options}->{config}      ? $params{options}->{config} :
        $OSNAME eq 'MSWin32'            ? 'registry'                 :
                                          'file';

    SWITCH: {
        if ($backend eq 'registry') {
            die "Unavailable configuration backend\n"
                unless $OSNAME eq 'MSWin32';
            $self->_loadFromRegistry();
            last SWITCH;
        }

        if ($backend eq 'file') {
            $self->_loadFromFile({
                file      => $params{options}->{'conf-file'},
                directory => $params{confdir},
            });
            last SWITCH;
        }

        if ($backend eq 'none') {
            last SWITCH;
        }

        die "Unknown configuration backend '$backend'\n";
    }

    $self->_loadUserParams($params{options});

    $self->_checkContent();

    return $self;
}

sub _loadDefaults {
    my ($self) = @_;

    foreach my $key (keys %$default) {
        $self->{$key} = $default->{$key};
    }
}

sub _loadFromRegistry {
    my ($self) = @_;

    my $Registry;
    Win32::TieRegistry->require();
    Win32::TieRegistry->import(
        Delimiter   => '/',
        ArrayValues => 0,
        TiedRef     => \$Registry
    );

    my $machKey = $Registry->Open('LMachine', {
        Access => Win32::TieRegistry::KEY_READ()
    }) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

    my $settings = $machKey->{"SOFTWARE/FusionInventory-Agent"};

    foreach my $rawKey (keys %$settings) {
        next unless $rawKey =~ /^\/(\S+)/;
        my $key = lc($1);
        my $val = $settings->{$rawKey};
        # Remove the quotes
        $val =~ s/\s+$//;
        $val =~ s/^'(.*)'$/$1/;
        $val =~ s/^"(.*)"$/$1/;

        if (exists $default->{$key}) {
            $self->{$key} = $val;
        } else {
            warn "unknown configuration directive $key";
        }
    }
}

sub _loadFromFile {
    my ($self, $params) = @_;
    my $file = $params->{file} ?
        $params->{file} : $params->{directory} . '/agent.cfg';

    if ($file) {
        die "non-existing file $file" unless -f $file;
        die "non-readable file $file" unless -r $file;
    } else {
        die "no configuration file";
    }

    my $handle;
    if (!open $handle, '<', $file) {
        warn "Config: Failed to open $file: $ERRNO";
        return;
    }

    while (my $line = <$handle>) {
        $line =~ s/#.+//;
        if ($line =~ /([\w-]+)\s*=\s*(.+)/) {
            my $key = $1;
            my $val = $2;

            # Remove the quotes
            $val =~ s/\s+$//;
            $val =~ s/^'(.*)'$/$1/;
            $val =~ s/^"(.*)"$/$1/;

            if (exists $default->{$key}) {
                $self->{$key} = $val;
            } else {
                warn "unknown configuration directive $key";
            }
        }
    }
    close $handle;
}

sub _loadUserParams {
    my ($self, $params) = @_;

    foreach my $key (keys %$params) {
        $self->{$key} = $params->{$key};
    }
}

sub _checkContent {
    my ($self) = @_;

    # check for deprecated options
    foreach my $old (keys %$deprecated) {
        next unless defined $self->{$old};

        next if $old =~ /^no-/ and !$self->{$old};

        my $handler = $deprecated->{$old};

        # notify user of deprecation
        warn "the '$old' option is deprecated, $handler->{message}\n";

        # transfer the value to the new option, if possible
        if ($handler->{new}) {
            if (ref $handler->{new} eq 'HASH') {
                # old boolean option replaced by new non-boolean options
                foreach my $key (keys %{$handler->{new}}) {
                    my $value = $handler->{new}->{$key};
                    if ($value =~ /^\+(\S+)/) {
                        # multiple values: add it to exiting one
                        $self->{$key} = $self->{$key} ?
                            $self->{$key} . ',' . $1 : $1;
                    } else {
                        # unique value: replace exiting value
                        $self->{$key} = $value;
                    }
                }
            } elsif (ref $handler->{new} eq 'ARRAY') {
                # old boolean option replaced by new boolean options
                foreach my $new (@{$handler->{new}}) {
                    $self->{$new} = $self->{$old};
                }
            } else {
                # old non-boolean option replaced by new option
                $self->{$handler->{new}} = $self->{$old};
            }
        }

        # avoid cluttering configuration
        delete $self->{$old};
    }

    # a logfile options implies a file logger backend
    if ($self->{logfile}) {
        $self->{logger} .= ',File';
    }

    # ca-cert-file and ca-cert-dir are antagonists
    if ($self->{'ca-cert-file'} && $self->{'ca-cert-dir'}) {
        die "use either 'ca-cert-file' or 'ca-cert-dir' option, not both\n";
    }

    # multi-values options, the default separator is a ','
    foreach my $option (qw/
            logger
            local
            server
            httpd-trust
            no-task
            no-category
            /) {

        if ($self->{$option}) {
            $self->{$option} = [split(/,/, $self->{$option})];
        } else {
            $self->{$option} = [];
        }
    }

    # files location
    $self->{'ca-cert-file'} =
        File::Spec->rel2abs($self->{'ca-cert-file'}) if $self->{'ca-cert-file'};
    $self->{'ca-cert-dir'} =
        File::Spec->rel2abs($self->{'ca-cert-dir'}) if $self->{'ca-cert-dir'};
    $self->{'logfile'} =
        File::Spec->rel2abs($self->{'logfile'}) if $self->{'logfile'};
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Config - Agent configuration

=head1 DESCRIPTION

This is the object used by the agent to store its configuration.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<confdir>

the configuration directory.

=item I<options>

additional options override.

=back
