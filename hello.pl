#!/usr/bin/env perl
use lib 'lib';
use Mojolicious::Lite;

get '/' => sub { shift->render(text => 'Hello World!') };
app->start;
