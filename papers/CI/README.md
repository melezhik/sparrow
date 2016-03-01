# Continue integration using sparrow tool chain

Sparrow is a tool to automate testing infrastructure. Automated testing
is essential part of continue integration processes as it provides fast feedback
on cases when something goes wrong.


Consider simple example of how sparrow could be used to build up some basic parts
of your infrastructure.

# web applicaton developement 

We have a simple Dancer2 application we are going to deploy on developer environment:


app.psgi

    #!/usr/bin/env perl
    use Dancer2;

    get '/' => sub {
        "Hello World!"
    };

    dance;


Let's keep source code at git repository:


    git init
    git add app.psgi
    git commit -a -m 'my web application'

    git remote add origin https://github.com/melezhik/foo.git
    git push -u origin master

# Development server

We are going to deploy application on dedicated server used for development environment:

    ssh dev.server
    git clone https://github.com/melezhik/foo.git
    cd webapp
    cpanm Dancer2
    plackup


In these lines we fetch source code from remote git repository and run dancer application. Good so far.
These steps could be automated in various ways ( jenkins, crontab , whatever your favourite CI tool ).

Last command should emit following:

    HTTP::Server::PSGI: Accepting connections at http://0:5000/

Which means our application is running.


# Building up test harness 

As we need to ensure that app is running correctly after get deployed we need some integration testing for it.
With sparrow it is as simple as writting a few lines of code:

    git init # let's keep test suite case under git
    echo 127.0.0.1:5000 > host
    echo 200 OK > get.txt
    echo 'Hello World!' >> get.txt
    echo '{}'> sparrow.json
    echo "requires 'swat';" > cpanfile
    git add .
    git commit -a -m 'basic test suite'
    git remote add origin https://github.com/melezhik/footest.git
    git push -u origin master 


Now when we are done with creating a very simple test suite let's go to developmet server and create some check points:

    ssh dev.server
    cpanm Sparrow
    echo "testapp https://github.com/melezhik/footest.git" > ~/sparrow.list      
    sparrow index update
    sparrow plg install testapp

    sparrow project create webapp
    sparrow check add webapp basic_suite
    sparrow check set  webapp basic_suite testapp
    
    sparrow check run webapp basic_suite

Output of last command will be:

    # running cd /home/vagrant/sparrow/plugins/private/testapp && carton exec 'swat ./   ' ...
    
    /home/vagrant/.swat/.cache/30818/prove/00.GET.t ..
    # trying ... curl -X GET -k --connect-timeout 20 -m 20 -L -f -D - '127.0.0.1:5000/'
    ok 1 - server returned successful response
    ok 2 - output match '200 OK'
    ok 3 - output match 'Hello World!'
    1..3
    ok
    All tests successful.
    Files=1, Tests=3,  0 wallclock secs ( 0.03 usr  0.00 sys +  0.04 cusr  0.00 csys =  0.07 CPU)
    Result: PASS
    

Ok, we see that our tests succeed and we can continue with development


# Adding new feature to web application

Let's add HTTP Basic authentication to your application:


app.psgi

    #!/usr/bin/env perl

    use Dancer2;
    use Dancer2::Plugin::Auth::Tiny;

    set show_errors => 1;
    set session     => 'Simple';


    get '/' => sub {
        "Hello World!"
    };


    get '/public' => sub { return 'public area' };

    get '/private' => needs login => sub { return 'private area' };

    get '/login' => sub {
        session "user" => "Robin Good";
        return "login and to back to " . params->{return_url};
    };

    get '/logout' => sub {
        app->destroy_session;
        redirect uri_for('/public');
    };

    dance;

