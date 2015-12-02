use lib '../lib';
use strict;
use warnings;

use XAS::Logmon::Parser::XAS::Logs;

my @lines = (
    "[2015-12-02 07:36:45] INFO  - starting up",
    "[2015-12-02 07:36:45] INFO  - connector: tcp_keepalive enabled",
    "[2015-12-02 07:36:45] INFO  - connector: connected to localhost on port 61613",
    "[2015-12-02 07:36:45] WARN  - alerts: resume processing",
    "[2015-12-02 07:36:45] WARN  - logs: resume processing",
    "[2015-12-02 09:34:24] WARN  - services: recieved signal TERM",
    "[2015-12-02 09:34:30] INFO  - shutting down",
);

my $default = XAS::Logmon::Parser::XAS::Logs->new();
my $tasks   = XAS::Logmon::Parser::XAS::Logs->new(format => ':tasks');

foreach my $line (@lines) {

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

    }

}

