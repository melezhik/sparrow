#!/usr/bin/env perl

use Mojolicious::Lite;

get '/echo-name' => sub {
  my $c = shift;
  $c->render( json => { name => $c->param('name') } )

};

