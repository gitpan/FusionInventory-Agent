package FusionInventory::Agent;

use strict;
use warnings;

use Cwd;
use English qw(-no_match_vars);
use UNIVERSAL::require;
use File::Glob;
use IO::Handle;
use POSIX ":sys_wait_h"; # WNOHANG

use FusionInventory::Agent::Config;
use FusionInventory::Agent::HTTP::Client::OCS;
use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::Task;
use FusionInventory::Agent::Target::Local;
use FusionInventory::Agent::Target::Server;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Hostname;
use FusionInventory::Agent::XML::Query::Prolog;

our $VERSION = '2.2.9902';
our $VERSION_STRING = versionString($VERSION);
our $AGENT_STRING = "FusionInventory-Agent_v$VERSION";

sub versionString {
    my ($VERSION) = @_;

    my $string = "FusionInventory Agent ($VERSION)";
    if ($VERSION =~ /^\d\.\d\.99(\d\d)/) {
        $string .= " **THIS IS A DEVELOPMENT RELEASE **";
    }

    return $string;
}

sub new {
    my ($class, %params) = @_;

    my $self = {
        status  => 'unknown',
        confdir => $params{confdir},
        datadir => $params{datadir},
        libdir  => $params{libdir},
        vardir  => $params{vardir},
    };
    bless $self, $class;

    return $self;
}

sub init {
    my ($self, %params) = @_;

    my $config = FusionInventory::Agent::Config->new(
        confdir => $self->{confdir},
        options => $params{options},
    );
    $self->{config} = $config;

    my $logger = FusionInventory::Agent::Logger->new(
        config   => $config,
        backends => $config->{logger},
        debug    => $config->{debug}
    );
    $self->{logger} = $logger;

    if ( $REAL_USER_ID != 0 ) {
        $logger->info("You should run this program as super-user.");
    }

    $logger->debug("Configuration directory: $self->{confdir}");
    $logger->debug("Data directory: $self->{datadir}");
    $logger->debug("Storage directory: $self->{vardir}");
    $logger->debug("Lib directory: $self->{libdir}");

    $self->{storage} = FusionInventory::Agent::Storage->new(
        logger    => $logger,
        directory => $self->{vardir}
    );

    # handle persistent state
    $self->_loadState();

    $self->{deviceid} = _computeDeviceId() if !$self->{deviceid};

    $self->_saveState();

    # create target list
    if ($config->{local}) {
        foreach my $path (@{$config->{local}}) {
            push @{$self->{targets}},
                FusionInventory::Agent::Target::Local->new(
                    logger     => $logger,
                    deviceid   => $self->{deviceid},
                    delaytime  => $config->{delaytime},
                    basevardir => $self->{vardir},
                    path       => $path,
                    html       => $config->{html},
                );
        }
    }

    if ($config->{server}) {
        foreach my $url (@{$config->{server}}) {
            push @{$self->{targets}},
                FusionInventory::Agent::Target::Server->new(
                    logger     => $logger,
                    deviceid   => $self->{deviceid},
                    delaytime  => $config->{delaytime},
                    basevardir => $self->{vardir},
                    url        => $url,
                    tag        => $config->{tag},
                );
        }
    }

    if (!$self->{targets}) {
        $logger->error("No target defined, aborting");
        exit 1;
    }

    if ($config->{daemon} && !$config->{'no-fork'}) {

        $logger->debug("Time to call Proc::Daemon");

        Proc::Daemon->require();
        if ($EVAL_ERROR) {
            $logger->error("Can't load Proc::Daemon. Is the module installed?");
            exit 1;
        }

        my $cwd = getcwd();
        Proc::Daemon::Init();
        $logger->debug("Daemon started");


        # If we use relative path, we must stay in the current directory
        if (substr( $params{libdir}, 0, 1 ) ne '/') {
            chdir($cwd);
        }

        if ($self->_isAlreadyRunning()) {
            $logger->debug("An agent is already runnnig, exiting...");
            exit 1;
        }
    }

    # compute list of allowed tasks
    my %available = $self->getAvailableTasks(disabledTasks => $config->{'no-task'});
    my @tasks = keys %available;

    $logger->debug("Available tasks:");
    foreach my $task (keys %available) {
        $logger->debug("- $task: $available{$task}");
    }

    $self->{tasks} = \@tasks;

    # create HTTP interface
    if (($config->{daemon} || $config->{service}) && !$config->{'no-httpd'}) {
        FusionInventory::Agent::HTTP::Server->require();
        if ($EVAL_ERROR) {
            $logger->debug("Failed to load HTTP server: $EVAL_ERROR");
        } else {
            # compute trusted addresses
            my $trust = $config->{'httpd-trust'};
            if ($config->{server}) {
                foreach my $url (@{$config->{server}}) {
                    push @{$config->{'httpd-trust'}}, URI->new($url)->host();
                }
            }

            $self->{server} = FusionInventory::Agent::HTTP::Server->new(
                logger          => $logger,
                agent           => $self,
                htmldir         => $self->{datadir} . '/html',
                ip              => $config->{'httpd-ip'},
                port            => $config->{'httpd-port'},
                trust           => $trust
            );
            $self->{server}->init();
        }
    }

    $logger->debug("FusionInventory Agent initialised");
}

sub run {
    my ($self) = @_;

    $self->{status} = 'waiting';

    if ($self->{config}->{daemon} || $self->{config}->{service}) {

        # background mode:
        while (1) {
            my $time = time();
            foreach my $target (@{$self->{targets}}) {
                next if $time < $target->getNextRunDate();

                eval {
                    $self->_runTarget($target);
                };
                $self->{logger}->fault($EVAL_ERROR) if $EVAL_ERROR;
                $target->resetNextRunDate();
            }

            # check for http interface messages
            $self->{server}->handleRequests() if $self->{server};
            delay(1);
        }
    } else {
        # foreground mode: check each targets once
        my $time = time();
        foreach my $target (@{$self->{targets}}) {
            if ($self->{config}->{lazy} && $time < $target->getNextRunDate()) {
                $self->{logger}->info(
                    "$target->{id} is not ready yet, next server contact " .
                    "planned for " . localtime($target->getNextRunDate())
                );
                next;
            }

            eval {
                $self->_runTarget($target);
            };
            $self->{logger}->fault($EVAL_ERROR) if $EVAL_ERROR;
        }
    }
}

sub _runTarget {
    my ($self, $target) = @_;

    # the prolog dialog must be done once for all tasks,
    # but only for server targets
    my $response;
    if ($target->isa('FusionInventory::Agent::Target::Server')) {
        my $client = FusionInventory::Agent::HTTP::Client::OCS->new(
            logger       => $self->{logger},
            timeout      => $self->{timeout},
            user         => $self->{config}->{user},
            password     => $self->{config}->{password},
            proxy        => $self->{config}->{proxy},
            ca_cert_file => $self->{config}->{'ca-cert-file'},
            ca_cert_dir  => $self->{config}->{'ca-cert-dir'},
            no_ssl_check => $self->{config}->{'no-ssl-check'},
        );

        my $prolog = FusionInventory::Agent::XML::Query::Prolog->new(
            deviceid => $self->{deviceid},
        );

        $response = $client->send(
            url     => $target->getUrl(),
            message => $prolog
        );
        die "No answer from the server" unless $response;

        # update target
        my $content = $response->getContent();
        if (defined($content->{PROLOG_FREQ})) {
            $target->setMaxDelay($content->{PROLOG_FREQ} * 3600);
        }
    }

    foreach my $name (@{$self->{tasks}}) {
        eval {
            $self->_runTask($target, $name, $response);
        };
        $self->{logger}->error($EVAL_ERROR) if $EVAL_ERROR;
        $self->{status} = 'waiting';
    }
}

sub _runTask {
    my ($self, $target, $name, $response) = @_;

    $self->{status} = "running task $name";

    if ($self->{config}->{daemon} || $self->{config}->{service}) {
        # server mode: run each task in a child process
        if (my $pid = fork()) {
            # parent
            while (waitpid($pid, WNOHANG) == 0) {
                $self->{server}->handleRequests() if $self->{server};
                delay(1);
            }
        } else {
            # child
            die "fork failed: $ERRNO" unless defined $pid;

            $self->{logger}->debug("running task $name in process $PID");
            $self->_runTaskReal($target, $name, $response);
            exit(0);
        }
    } else {
        # standalone mode: run each task directly
        $self->{logger}->debug("running task $name");
        $self->_runTaskReal($target, $name, $response);
    }
}

sub _runTaskReal {
    my ($self, $target, $name, $response) = @_;

    my $class = "FusionInventory::Agent::Task::$name";

    $class->require();

    my $task = $class->new(
        config       => $self->{config},
        confdir      => $self->{confdir},
        datadir      => $self->{datadir},
        logger       => $self->{logger},
        target       => $target,
        deviceid     => $self->{deviceid},
    );

    if (!$task->isEnabled($response)) {
        $self->{logger}->info("task $name execution not requested");
        return;
    }

    $task->run(
        user         => $self->{config}->{user},
        password     => $self->{config}->{password},
        proxy        => $self->{config}->{proxy},
        ca_cert_file => $self->{config}->{'ca-cert-file'},
        ca_cert_dir  => $self->{config}->{'ca-cert-dir'},
        no_ssl_check => $self->{config}->{'no-ssl-check'},
    );
}

sub getStatus {
    my ($self) = @_;
    return $self->{status};
}

sub getTargets {
    my ($self) = @_;

    return @{$self->{targets}};
}

sub getAvailableTasks {
    my ($self, %params) = @_;

    my %tasks;
    my %disabled  = map { lc($_) => 1 } @{$params{disabledTasks}};

    # tasks may be located only in agent libdir
    my $directory = $self->{libdir};
    $directory =~ s,\\,/,g;
    my $subdirectory = "FusionInventory/Agent/Task";
    # look for all perl modules here
    foreach my $file (File::Glob::glob("$directory/$subdirectory/*.pm")) {
        next unless $file =~ m{($subdirectory/(\S+)\.pm)$};
        my $module = file2module($1);
        my $name = file2module($2);

        next if $disabled{lc($name)};

        my $version;
        if ($self->{config}->{daemon} || $self->{config}->{service}) {
            # server mode: check each task version in a child process
            my ($reader, $writer);
            pipe($reader, $writer);
            $writer->autoflush(1);

            if (my $pid = fork()) {
                # parent
                close $writer;
                $version = <$reader>;
                close $reader;
                waitpid($pid, 0);
            } else {
                # child
                die "fork failed: $ERRNO" unless defined $pid;

                close $reader;
                $version = $self->_getTaskVersion($module);
                print $writer $version if $version;
                close $writer;
                exit(0);
            }
        } else {
            # standalone mode: check each task version directly
            $version = $self->_getTaskVersion($module);
        }

        # no version means non-functionning task
        next unless $version;

        $tasks{$name} = $version;
    }

    return %tasks;
}

sub _getTaskVersion {
    my ($self, $module) = @_;

    my $logger = $self->{logger};

    if (!$module->require()) {
        $logger->debug2("module $module does not compile: $@") if $logger;
        return;
    }

    if (!$module->isa('FusionInventory::Agent::Task')) {
        $logger->debug2("module $module is not a task") if $logger;
        return;
    }

    my $version;
    {
        no strict 'refs';  ## no critic
        $version = ${$module . '::VERSION'};
    }

    return $version;
}

sub _isAlreadyRunning {
    my ($self) = @_;

    Proc::PID::File->require();
    if ($EVAL_ERROR) {
        $self->{logger}->debug(
            'Proc::PID::File unavailable, unable to check for running agent'
        );
        return 0;
    }

    return Proc::PID::File->running();
}

sub _loadState {
    my ($self) = @_;

    my $data = $self->{storage}->restore(name => 'FusionInventory-Agent');

    $self->{deviceid} = $data->{deviceid} if $data->{deviceid};
}

sub _saveState {
    my ($self) = @_;

    $self->{storage}->save(
        name => 'FusionInventory-Agent',
        data => {
            deviceid => $self->{deviceid},
        }
    );
}

# compute an unique agent identifier, based on host name and current time
sub _computeDeviceId {
    my $hostname = FusionInventory::Agent::Tools::Hostname::getHostname();

    my ($year, $month , $day, $hour, $min, $sec) =
        (localtime (time))[5, 4, 3, 2, 1, 0];

    return sprintf "%s-%02d-%02d-%02d-%02d-%02d-%02d",
        $hostname, $year + 1900, $month + 1, $day, $hour, $min, $sec;
}

1;
__END__

=head1 NAME

FusionInventory::Agent - Fusion Inventory agent

=head1 DESCRIPTION

This is the agent object.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<confdir>

the configuration directory.

=item I<datadir>

the read-only data directory.

=item I<vardir>

the read-write data directory.

=item I<options>

the options to use.

=back

=head2 init()

Initialize the agent.

=head2 run()

Run the agent.

=head2 getStatus()

Get the current agent status.

=head2 getTargets()

Get all targets.

=head2 getAvailableTasks()

Get all available tasks found on the system, as a list of module / version
pairs:

%tasks = (
    'Foo' => x,
    'Bar' => y,
);
