use Mojolicious::Lite;

get '/' => sub {

    my $c = shift;

    $c->stash( msg => '' );

    $c->render( template => 'index' );

};



get '/add_app_form' => 'add_app_form';

get '/add_plg_form' => 'add_plg_form';


get '/add_app' => sub {

    my $c = shift;

    my $app = $c->param('name');

    $c->stash( msg => "app $app added");

    $c->render( template => 'index' );

};


get '/add_plg' => sub {

    my $c = shift;

    my $pname = $c->param('name');

    $c->stash( msg => "plugin $pname added");

    $c->render( template => 'index' );


};


app->start;

__DATA__

@@ index.html.ep
% if ($msg) { 
    %= "=== $msg ==="
    %= tag 'br'
    %= tag 'br'
% }

%= link_to 'Add app' => 'add_app_form'

%= link_to 'Add plugin' => 'add_plg_form'

@@ add_app_form.html.ep

%= form_for add_app => begin
  %= text_field 'name'
  %= submit_button
% end

@@ add_plg_form.html.ep

%= form_for add_plg => begin
  %= text_field 'name'
  %= submit_button
% end
