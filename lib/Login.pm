package Login;
use Mojo::Base 'Mojolicious';

use MyUsers;

sub startup {
  my $self = shift;

  $self->helper(users => sub { state $users = MyUsers->new });

  my $r = $self->routes;
  $r->any('/')->to('login#index')->name('index');
  my $logged_in = $r->under->to('login#logged_in');
  $logged_in->get('/dashboard')->to('login#dashboard');
  $r->get('/logout')->to('login#logout');
}

1;