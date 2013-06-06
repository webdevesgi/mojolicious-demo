package Login::Login;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;
use MIME::Base64;

sub index {
  my $self = shift;

  my $user = $self->param('user') || '';
  my $pass = $self->param('pass') || '';
  return $self->render unless $self->users->check($user, $pass);

  $self->session(user => $user);
  $self->flash(message => 'Vous êtes maintenant connecté.');
  $self->redirect_to('dashboard');
}

sub logged_in {
  my $self = shift;

  $self->stash(
      urls => $self->urls->getUrls($self->session('user'))
    );
  return $self || !$self->redirect_to('index');
}

# Post
sub sendurl{
  my $self = shift;

  # Si c'est bien une URL
  my $url =  Mojo::URL->new($self->param('orig_url'));
  if(!$url->is_abs){
    return $self->redirect_to('dashboard');
  }
  # Retoune url raccourcie
  my $short_url = encodeurl($self->param('orig_url'));

  $self->urls->addUrl($self->session('user'), $self->param('orig_url'), $short_url);
  return $self->redirect_to('dashboard');
}

sub logout {
  my $self = shift;
  $self->session(expires => 1);
  $self->redirect_to('index');
}

sub encodeurl{
    my ($url_orig) = @_;
    chomp $url_orig;
    my $b64_url = encode_base64($url_orig, "");

    my $short_url = "!".sprintf("%x",time);

    return $short_url;
}

sub decode {
  my $self = shift;

  my $origin_url = $self->urls->checkUrl($self->param('id'));
  print Dumper $origin_url;
  return $self->redirect_to('index') unless $origin_url;


  $self->urls->updateClics($self->param('id'));
  $self->redirect_to($origin_url);

}

1;