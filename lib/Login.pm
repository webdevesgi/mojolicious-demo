package Login;
use Mojo::Base 'Mojolicious';

use MyUsers;
use Urls;
use Connexion;

sub startup {
  my $self = shift;

  $self->helper(users => sub { state $users = MyUsers->new });
  $self->helper(urls => sub { state $urls = Urls->new });

  my $r = $self->routes;

  $r->get('/l/:id')->to('login#decode');

  $r->any('/register')->to('login#register')->name('register');

  $r->any('/registered')->to('login#registered');

  $r->any('/')->to('login#index')->name('index');

  my $logged_in = $r->under->to('login#logged_in');

  $logged_in->post('/sendurl')->to('login#sendurl');

  $logged_in->get('/dashboard')->to('login#dashboard');

  $r->get('/logout')->to('login#logout');
}

1;