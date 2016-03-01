# continuous integration using sparrow tool chain

Sparrow is a tool to automate testing infrastructure. Automated testing
is essential part of continuous integration processes as it provides fast feedback
on cases when something goes wrong.


Consider simple example of how sparrow could be used to build up some basic parts
of your infrastructure.

# web application development 

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

    git remote add origin https://github.com/melezhik/webapp.git
    git push -u origin master

# development server

We are going to deploy application on dedicated server used for development environment:

    ssh dev.server
    git clone https://github.com/melezhik/webapp.git
    cd webapp
    cpanm Dancer2
    plackup


In these lines we fetch source code from remote git repository and run dancer application. Good so far.
These steps could be automated in various ways ( jenkins, crontab , whatever your favorite CI tool ).

Last command should emit following:

    HTTP::Server::PSGI: Accepting connections at http://0:5000/

Which means our application is running.


# building up test harness 

As we need to ensure that app is running correctly after get deployed we need some integration testing for it.
With sparrow it is as simple as writing a few lines of code:

    git init # let's keep test suite case under git
    echo 127.0.0.1:5000 > host
    echo 200 OK > get.txt
    echo 'Hello World!' >> get.txt
    echo '{}'> sparrow.json
    echo "requires 'swat';" > cpanfile
    git add .
    git commit -a -m 'basic test suite'
    git remote add origin https://github.com/melezhik/webapp-basic-check.git
    git push -u origin master 


Now when we are done with creating a very simple test suite let's go to development server and create some check points:

    ssh dev.server
    cpanm Sparrow

    echo "basic-check https://github.com/melezhik/webapp-basic-check.git" > ~/sparrow.list      
    sparrow index update
    sparrow plg install basic-check

    sparrow project create webapp
    sparrow check add webapp basic
    sparrow check set  webapp basic basic-check
    
    sparrow check run webapp basic

Output of last command will be:

    # running cd /home/vagrant/sparrow/plugins/private/basic-check && carton exec 'swat ./   ' ...
    
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
    

Ok, we see that our tests succeed and we can continue with development.


# adding new feature to web application

Let's add authentication to your application:


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


Let's create a check list we need to ensure:

* when user hits /public route he sees 'public area'
* when user hits /private route for a first time he gets redirected to /login page and then gets a session cookies
* when user hits /private routes for a second time he sees 'private area'

Now create another suite case for the stories above, we are going to keep under another git repository and
then deliver tests as another sparrow plugin as we did with the basic suite case:


## creating test suite skeleton

    git init
    echo 127.0.0.1:5000 > host
    echo '{}'> sparrow.json
    echo "requires 'swat';" > cpanfile
    git add .
    git commit -a -m 'authentication test suite'
    git remote add origin https://github.com/melezhik/webapp-auth-check.git
    git push -u origin master 


## public area test

    mkdir public
    echo 200 OK > public/get.txt
    echo 'public area' >> public/get.txt


## private area first time 

    mkdir private-first-time
    nano private-first-time/hook.pm

        run_swat_module( GET => '/logout' );
        run_swat_module( GET => '/private' , { auth => 0 } );
        set_response('done');

    echo done > private-first-time/get.txt

    mkdir logout/
    echo swat_module=1 > logout/swat.ini
    echo 200 OK > logout/get.txt

    mkdir private/

    nano private/swat.ini

        swat_module=1
        curl_params="-b ${test_root_dir}/cook.txt"

    nano private/get.txt

        generator: [ module_variable('auth') ? 'private area' : 'login and to back to' ]

## private area second time 

    mkdir private-second-time
    nano private-second-time/hook.pm

        run_swat_module( GET => '/login' );
        run_swat_module( GET => '/private' , { auth => 1 } );
        set_response('done');

    mkdir login/

    nano login/swat.ini

        swat_module=1
        curl_params="-c ${test_root_dir}/cook.txt"

    echo 200 OK > login/get.txt




And finally we can commit changes to git and push them to remote.

    git add .
    git commit -a -m 'authentication check test suite'
    git push

    
# testing new features

As we did with basic test suite we now are able to run tests for authentication feature:


    ssh dev.server
    echo "auth-check https://github.com/melezhik/webapp-auth-check.git" >> ~/sparrow.list      
    sparrow index update
    sparrow plg install auth-check

    sparrow check add webapp auth
    sparrow check set  webapp auth auth-check
    
    sparrow check run webapp auth


The output of the second test suite will be:

    # running cd /home/vagrant/sparrow/plugins/private/testapp2 && carton exec 'swat ./   ' ...
    
    /home/vagrant/.swat/.cache/1085/prove/private-first-time/00.GET.t ...
    # trying ... curl -X GET -k --connect-timeout 20 -m 20 -L -f -D - '127.0.0.1:5000/logout'
    ok 1 - server returned successful response
    ok 2 - output match '200 OK'
    # trying ... curl -X GET -k --connect-timeout 20 -m 20 -L -b /home/vagrant/.swat/.cache/1085/prove/cook.txt -f -D - '127.0.0.1:5000/private'
    ok 3 - server returned successful response
    ok 4 - output match 'login and to back to'
    ok 5 - server response is spoofed
    # response saved to /home/vagrant/.swat/.cache/1085/prove/xDQuPGlVog
    ok 6 - output match 'done'
    1..6
    ok
    /home/vagrant/.swat/.cache/1085/prove/public/00.GET.t ...............
    # trying ... curl -X GET -k --connect-timeout 20 -m 20 -L -f -D - '127.0.0.1:5000/public'
    ok 1 - server returned successful response
    ok 2 - output match '200 OK'
    ok 3 - output match 'public area'
    1..3
    ok
    /home/vagrant/.swat/.cache/1085/prove/private-second-time/00.GET.t ..
    # trying ... curl -X GET -k --connect-timeout 20 -m 20 -L -c /home/vagrant/.swat/.cache/1085/prove/cook.txt -f -D - '127.0.0.1:5000/login'
    ok 1 - server returned successful response
    ok 2 - output match '200 OK'
    # trying ... curl -X GET -k --connect-timeout 20 -m 20 -L -b /home/vagrant/.swat/.cache/1085/prove/cook.txt -f -D - '127.0.0.1:5000/private'
    ok 3 - server returned successful response
    ok 4 - output match 'private area'
    ok 5 - server response is spoofed
    # response saved to /home/vagrant/.swat/.cache/1085/prove/hvtwlrTqEZ
    ok 6 - output match 'done'
    1..6
    ok
    All tests successful.
    Files=3, Tests=15,  0 wallclock secs ( 0.03 usr  0.01 sys +  0.17 cusr  0.01 csys =  0.22 CPU)
    Result: PASS
    
    
# Summary

Sparrow tool chains has following features:

* integration tests suites are decoupled from application code

* tests could be grouped by types/environments and developed/delivered as dedicated test suites - aka sparrow plugins

* sparrow test infrastructure is easy to bootstrap on different environments (dev,test,prod) - everybody involved
is able now to run desired test suite with easiness

* swat output is intended to make it easy, clear debugging/troubleshooting  process, in most case you just rerun curl command ( against tested server )
with parameters extracted from test output.

 

