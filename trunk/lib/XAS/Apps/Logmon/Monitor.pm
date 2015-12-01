package XAS::Apps::Logmon::Monitor;

our $VERSION = '0.01';

use XAS::Lib::Process;

use XAS::Class
  debug      => 0,
  version    => $VERSION,
  base       => 'XAS::Lib::App::Service',
  mixin      => 'XAS::Lib::Mixins::Configs',
  utils      => 'dotid trim',
  constants  => 'TRUE FALSE',
  accessors  => 'cfg',
  filesystem => 'File Dir',
  vars => {
    SERVICE_NAME         => 'XAS_Log',
    SERVICE_DISPLAY_NAME => 'XAS Log Monitor',
    SERVICE_DESCRIPTION  => 'Monitor log files'
  }
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub setup {
    my $self = shift;

    my @sections = $self->cfg->Sections();

    foreach my $section (@sections) {

        next if ($section !~ /^logmon:/);

        my ($alias)  = $section =~ /^logmon:(.*)/;
        my $ignore   = $self->cfg->val($section, 'ignore', '30');
        my $filename = File($self->cfg->val($section, 'filename', '/var/logs/xas/xas-spooler.log'));
        my $spooldir = Dir($self->cfg->val($section, 'spooldir', '/var/spool/xas/logs'));
        my $command  = File($self->cfg->val($section, 'command'));
        my $pidfile  = File($self->env->run, $command->basename . '-' . $filename->basename . '.pid');

        my $command = sprintf('%s --filename %s --spooldir %s --ignore %s --pid-file %s --log-type console',
            $command,
            $filename,
            $spooldir,
            $ignore,
            $pidfile,
        );

        $alias = trim($alias);

        my $process = XAS::Lib::Process->new(
            -alias          => $alias,
            -pty            => 1,
            -command        => $command,
            -auto_start     => $self->cfg->val($section, 'auto-start', TRUE),
            -auto_restart   => $self->cfg->val($section, 'auto-restart', TRUE),
            -directory      => Dir($self->cfg->val($section, 'directory', "/")),
            -exit_codes     => $self->cfg->val($section, 'exit-codes', '0,1'),
            -exit_retries   => $self->cfg->val($section, 'exit-retires', -1),
            -group          => $self->cfg->val($section, 'group', 'xas'),
            -priority       => $self->cfg->val($section, 'priority', '0'),
            -umask          => $self->cfg->val($section, 'umask', '0022'),
            -user           => $self->cfg->val($section, 'user', 'xas'),
            -redirect       => 1,
            -output_handler => sub {
                my $output = shift;
                my ($level) = $output =~ /\s+(\w+)\s+-/;
                my ($line)  = $output =~ /\s+-(.*)/;
                $level = lc(trim($level)) || 'info';
                $line  = trim($line) || '';
                $self->log->$level(sprintf('%s: %s', $alias, $line));
            }
        );

        $self->service->register($alias);

    }

}

sub main {
    my $self = shift;

    $self->log->info_msg('startup');

    $self->setup();
    $self->service->run();

    $self->log->info_msg('shutdown');

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

sub init {
    my $class = shift;

    my $self = $class->SUPER::init(@_);

    $self->load_config();

    return $self;

}

1;

__END__

=head1 NAME

XAS::Apps::Logmon::Monitor - A class for the XAS environment

=head1 SYNOPSIS

 use XAS::Apps::Logmon::Monitor;


=head1 DESCRIPTION

This module will spawn multiple log monitoring processes. It will keep track
of them and restart them if they should stop.

=head1 METHODS

=head2 setup

This method will process the config file and spawn log monitoring processes.

=head2 main

This method will start the processing.

=head2 options

This method defines the command line options.

=head1 SEE ALSO

=over 4

=item L<XAS::Logmon>

=item L<XAS|XAS>

=back

=head1 AUTHOR

Kevin L. Esteb, E<lt>kevin@kesteb.usE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2012-2015 Kevin L. Esteb

This is free software; you can redistribute it and/or modify it under
the terms of the Artistic License 2.0. For details, see the full text
of the license at http://www.perlfoundation.org/artistic_license_2_0.

=cut
