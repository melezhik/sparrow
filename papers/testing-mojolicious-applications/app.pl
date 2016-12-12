#!/usr/bin/env perl

use Mojolicious::Lite;

get '/' => sub {
  my $c = shift;
  $c->render( text => 'welcome page')

};

get '/hello' => sub  {

  my $c = shift;
  $c->render( text => 'hello '.($c->param('name')))

};

get '/bye' => sub {

  my $c = shift;
  $c->render( text => 'bye '.($c->param('name')))

};

app->start;
