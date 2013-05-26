package Connexion;

use DBI;
use strict;
use warnings;

sub new {

  my $database = 'mojo';
  my $userdata = 'mojo';
  my $password = 'mojo';

  return DBI->connect("DBI:mysql:$database", $userdata, $password);

}

1;