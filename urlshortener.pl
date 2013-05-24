#! /usr/bin/env perl
use lib 'lib';
use Mojolicious::Lite;
use MIME::Base64;

# Fonctions
# ---------------------------
# Enregistre l'url dans fichier urls
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

# Récupère l'url dans fichier urls
sub get_url{
    my ($short_url) = @_;
    my $self = shift;

    open(FILE, "urls.txt") || die;

    # Lecture non bloquante
    flock(FILE, 4);
    while(<FILE>){
        if ($_ =~ /$short_url/){
            my @url_line = split(/\|/,$_);
            return decode_base64($url_line[1]);
        }
    }
    close(FILE);
    # Url non trouvee, retourne -1
    return -1;
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

# Urlshortener
get '/:shorturl' => ([shorturl => qr/\![a-f0-9]{8}/]) => sub {
    my $self = shift;

    my $redirect_url = get_url($self->param('shorturl'));
    if($redirect_url == "-1"){
        return $self->redirect_to('index');
    }else{
         return $self->redirect_to($redirect_url);
    }

};

# Lancement
app->start();


# Vues
# ---------------------------
__DATA__
# Layout
@@ layouts/default.html.ep
<!doctype html><html>
    <head><title><%= title %></title>
    <link href="http://bootswatch.com/cosmo/bootstrap.min.css" media="screen" rel="stylesheet" />
    </head>
    <body><div class="navbar navbar-fixed-top">
    <div class="navbar-inner">
     <div class="container">
       <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
         <span class="icon-bar"></span>
         <span class="icon-bar"></span>
         <span class="icon-bar"></span>
       </a>
       <a class="brand" href="/">Url Shortener</a>
       <div class="nav-collapse collapse" id="main-menu">
        <ul class="nav" id="main-menu-left">
          <li><a href="/">News</a></li>
        </ul>
       </div>
     </div>
   </div>
 </div><div id="content"><%= content %></div></body>
</html>

@@ index.html.ep
% layout 'default';
% title 'Acceuil';
<%= form_for sendurl => (method => 'post') => begin %>
    <p>URL :
    <%= text_field 'orig_url' %>
    <%= submit_button 'Raccourcir' %>
    </p>
<% end %>

@@ confirm.html.ep
% layout 'default';
% title 'Confirmation';
<h1><a href="/">shorturl.local</a></h1>
<p>Votre adresse a ete enregistree</p><br>
<% if ($port == 80) { %>
    <p>URL courte : <a href="http://<%=$host%>/<%=$shortened%>">http://<%=$host%>/<%=$shortened%></a></p><br>
<%} else { %>
    <p>URL courte : <a href="http://<%=$host%>:<%=$port%>/<%=$shortened%>">http://<%=$host%>:<%=$port%>/<%=$shortened%></a></p><br>
<% } %>
<a href="/">retour</a> 
