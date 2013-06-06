package MyUsers;

use Connexion;
use warnings;

sub new { bless {}, shift }

sub check {
  my ($self, $user, $pass) = @_;
  our(@z);

  my $dbh = Connexion->new();

  my $t = $dbh->prepare("SELECT name FROM users WHERE name = '$user' AND password = '$pass' ");
  $t->execute();

  @z = $t -> fetchrow_array;

  if(@z != ''){
    return 1
  }else{
    return undef;
  }
}

sub exist {
  my ($self, $user) = @_;
  our(@z);

  my $dbh = Connexion->new();

  my $t = $dbh->prepare("SELECT name FROM users WHERE name = '$user' ");
  $t->execute();

  @z = $t -> fetchrow_array;

  if(@z != ''){
    return 1
  }else{
    return undef;
  }
}

sub createUser {
  my ($self, $user, $password) = @_;
  our(@z);

  my $dbh = Connexion->new();

  my $t = $dbh->prepare("INSERT INTO users (name, password) VALUES ('$user', '$password') ");
  $t->execute();
}

1;