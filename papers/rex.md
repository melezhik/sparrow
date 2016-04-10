# SYNOPSIS

Server automation with rex and sparrow

# Using rex and sparrow to automate your server infrastructure

Rex - is a server automation tool written on perl, using ssh rex allow you execute various commands
on your server remotely. Well rex is able to do more ;), check out rex documentation!

Sparrow is tool to install and run outthentic test suites - various tests to ensure your system
works as expected. Under the hood every sparrow plugin ( test suite ) - is small test case to
run some system commands and verify/analyze their output. It is very similar to what a system
administrators do on daily basis, but this is run automatically.

# Hello world example

Consider simple example of installing web application from source code using carton and
ensure it runs ok, namely a proper process is seen in the processes list and pid file provides
valid process ID.


# Application

Let's create a simple dancer application:


  $ cat app.pl

  use Dancer2;
  get '/' => sub { "Hello World" };
  dance;    
  

That's it. Real application is of course has more files and complex structure but for the 
purpose of this tutorial it is enough.


Let's keep source code at git repository:


  $ git init
  $ git add.pl
  $ git commit -a -m 'application file'
  $ git remote add origin master http://your.git.repo.app
  $ git push


Ok. Now we are ready to deploy things with rex:


# Rexfile


Rexfile should defined a task to `git clone` our source code and run dancer application:


  $ cat Rexfile

  use Rex::Misc::ShellBlock;

  task "deploy", sub {
    shell_block <<'EOF';
      rm -rf ~/app
      git clone http://your.git.repo.app
      cd app
      nohup dance & echo -n $! > app.pid
    EOF
  };


Again for the sake of simplicity of our tutorial we intentionally assume that some conditions are met on our
server:

* we have git installed
* we have Dancer2 package installed
* we have nohup utility

Ok now let run our rex task:


  $ rex -H my.app.server deploy


If everything is fine, we will have our application running on our server.


