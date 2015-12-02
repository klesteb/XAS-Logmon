use lib '../lib';
use strict;
use warnings;

use Data::Dumper;
use XAS::Logmon::Parser::XAS::Logs;

my $parser = XAS::Logmon::Parser::XAS::Logs->new();

warn Dumper($parser);

$parser = XAS::Logmon::Parser::XAS::Logs->new(format => ':tasks');

warn Dumper($parser);
