#! /usr/bin/env perl
use lib 'lib';
use Mojolicious::Lite;
use MIME::Base64;

# Fonctions
# ---------------------------
sub store_url{
    my ($url_orig) = @_;
    chomp $url_orig;
    my $b64_url = encode_base64($url_orig, "");

    my $short_url = "!".sprintf("%x",time);

    open(STORAGE, ">> urls.txt") or die "erreur d'acces au stockage\n$!";
    print STORAGE "$short_url|$b64_url\n";
    close STORAGE;

    return $short_url;
}

# Controllers
# ---------------------------
# Home
get '/' => sub {
    my $self = shift;
    return $self->render;
} => 'index';

# Post
post '/sendurl' => sub {
    my $self = shift;
    print($self);

    # Si c'est bien une URL
    my $url =  Mojo::URL->new($self->param('orig_url'));
    if(!$url->is_abs){
      return $self->redirect_to('index');
    }

    # Retoune url raccourcie
    my $short_url = store_url($self->param('orig_url'));

    # retourne les valeurs
    return $self->render('confirm', shortened => $short_url, host => $self->req->url->base->host, port => $self->req->url->base->port);
};

# Lancement
app->start();


# Vues
# ---------------------------
__DATA__
# Layout
@@ layouts/default.html.ep
<!doctype html><html>
    <head><title>Url Shortener</title></head>
    <body><%= content %></body>
</html>

@@ index.html.ep
% layout 'default';
<%= form_for sendurl => (method => 'post') => begin %>
    <h1><a href="/">Url Shortener</a></h1>
    <p>URL :
    <%= text_field 'orig_url' %> 
    <%= submit_button 'Raccourcir' %>
    </p>
<% end %>

@@ confirm.html.ep
% layout 'default';
<h1><a href="/">shorturl.local</a></h1>
<p>Votre adresse a ete enregistree</p><br>
<% if ($port == 80) { %>
    <p>URL courte : <a href="http://<%=$host%>/<%=$shortened%>">http://<%=$host%>/<%=$shortened%></a></p><br>
<%} else { %>
    <p>URL courte : <a href="http://<%=$host%>:<%=$port%>/<%=$shortened%>">http://<%=$host%>:<%=$port%>/<%=$shortened%></a></p><br>
<% } %>

<a href="/">retour</a>