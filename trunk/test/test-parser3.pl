use lib '../lib';
use strict;
use warnings;

use Badger::Filesystem 'File';
use XAS::Logmon::Input::File;
use XAS::Logmon::Parser::XAS::Logs;

my $input = XAS::Logmon::Input::File->new(
    -filename => File('/var/log/xas/xas-spooler.log')
);

my $default = XAS::Logmon::Parser::XAS::Logs->new();
my $tasks   = XAS::Logmon::Parser::XAS::Logs->new(format => ':tasks');

while (my $line = $input->get()) {

    if (my $data = $tasks->parse($line)) {

        warn "tasks---------\n";

        foreach my $key (keys($data)) {

            warn sprintf("%s: %s\n", $key, $data->{$key});

        }

        next;

    }

    if (my $data = $default->parse($line)) {

        warn "default-------\n";

        foreach my $key (keys($data)) {

            warn sprintf("%s: %s\n", $key, $data->{$key});

        }

        next;

    }

    warn sprintf("invalid: %s\n", $line);

}

