In this post I am going to show how you can use Sparrow to test 
mojolicious applications.


Sparrow approach to test things differ from convenient unit tests approach, practically this means:

* a tested code is treated as black box rather than unit test way where you relies deeply on inner application
structure

* a sparrow test suites are not a part of CPAN distribution ( the one you keep under t/* ) and gets
run NOT during distribution install (`make test` stage)

* sparrow test suite code is decoupled from tested application code and is better to be treated
as third party tests for your application

* sparrow tests suites have it's own life cycle and get released _in parallel_ with tested application
 

Ok, let's go to the practical example.


A Mojolicious comes with some handy tools to invoke a http requests against web application.

Consider simple mojolicious code:


    #!/usr/bin/env perl
    
    use Mojolicious::Lite;
    
    get '/' => {text => 'hello world'};
    
    app->start;
    

Now we can quickly test a `GET /` route with help of mojolicious `get` command:



    ./app.pl get /
    [Sun Dec 11 17:23:38 2016] [debug] GET "/"
    [Sun Dec 11 17:23:38 2016] [debug] 200 OK (0.000456s, 2192.982/s)
    hello world    

That's ok. This is going to be a base for out first sparrow test:


    $ nano story.bash

    $project_root_dir./app.pl get /


    $ nano story.check

    hello world


    $ strun
    
    / started
    
    [Sun Dec 11 17:45:28 2016] [debug] GET "/"
    [Sun Dec 11 17:45:28 2016] [debug] 200 OK (0.000469s, 2132.196/s)
    hello world
    ok      scenario succeeded
    ok      output match 'hello world'
    STATUS  SUCCEED
    
What we have done here.

* created a story to run `GET /` against mojolicious application - file named story.bash
* created a story check file to validate data returned from http request.
* finally run a test suite ( story ) with the help of so called story runner - strun

More about stories and check files could be found at [Outthentic](https://metacpan.org/pod/Outthentic) - a module for execution sparrow scripts.


Consider a negative here, when test fails. For this let's change a check file to express we need 
another string returned from calling `GET /` route:

 
    $ nano story.check

    hello sparrow


    $ strun

    / started
    
    [Sun Dec 11 18:18:07 2016] [debug] GET "/"
    [Sun Dec 11 18:18:07 2016] [debug] 200 OK (0.001237s, 808.407/s)
    hello world
    ok      scenario succeeded
    not ok  output match 'hello sparrow'
    STATUS  FAILED (256)
    


