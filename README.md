# NAME

Sparrow

[![Build Status](https://travis-ci.org/melezhik/sparrow.svg)](https://travis-ci.org/melezhik/sparrow)
 
# SYNOPSIS

Sparrow - outthentic tests manager.  Manages outthentic family test suites.

# CAVEAT

The project is still in very alpha stage. Things might change. But you can start play with it :-)


# INSTALL

    $ sudo yum install git
    $ sudo yum install curl # skip this if you are not going to use private sparrow plugins
    $ cpanm Sparrow

# Glossary 

## Outthentic family frameworks

* Outthentic tests are those using [Outthentic DSL](https://github.com/melezhik/outthentic-dsl).

* Currently there are two members of outthentic family test frameworks:

  * [swat](https://github.com/melezhik/swat) - web application testing framework.

  * [outthentic](https://github.com/melezhik/outthentic) - generic purposes testing framework.

So, _swat test suites_ are those running under swat framework

So, _generic test suites_ are those running under outthentic framework

* In the documentation below term \`outthentic tests' relates both to swat and generic tests.

## Sparrow plugins

Reusable \`outthentic tests' distributed via outthentic tests repository - [SparrowHub](https://sparrowhub.org)
are called sparrow plugins.

## Sparrow tool

`sparrow` is a console client to install, setup and run sparrow plugins.

## SparrowHub

[Central repository](https://sparrowhub.org) of sparrow plugins 


# Sparrow basic entities

Basically you deal with 3 type of entities:

## plugins

A sparrow plugins which you search, install and (optionally) configure. Usually plugin is a small
monitoring / testing suite to solve a specific issue. For example check available disk space of
ensure service is running. There are a plenty of plugins at SparrowHub.


## checkpoint 

Checkpoint is configurable sparrow plugin. Some sparrow does not require configuration and could be run as is,
but many require some piece of input data to bind to. For example hostname or internal plugin parameters
to adjust plugin logic. Checkpoint is a container for:

* plugin
* plugin configuration


Plugin configuration is just a text file in one of 2 formats:

* .ini style format
* YAML format

You could read about plugin configuration further in this documentation.


## projects

Projects are logic groups of sparrow checkpoints. It's convenient to split a whole list of checkpoint to
different logical groups. Like one for system checks - disk available space or RAM status, other
for web servers status so on. 

# API

Now having a knowledges about basic sparrow entities let's dive  into sparrow API provided by `sparrow`
console client.


## create a project

*sparrow project create $project\_name*

Create a sparrow project.

Sparrow project is a logical group of sparrow plugins and their

Example command:

    # system level check
    sparrow project create system

    sparrow project create production-web-servers

To get project info say this:

*sparrow project show $project\_name*

For example:

    sparrow project show dev-db-servers

To see projects list say this:

*sparrow project list*

To remove project data say this:

*sparrow project remove $project\_name*

For example:

    sparrow project qa-db-servers remove

## search sparrow plugins

Sparrow plugin is a shareable outthentic test suite.

One could install sparrow plugin and then run related outthentic tests, see [check](#run-tests) action for details.

To search available plugins say this:

*sparrow plg search $pattern*

For example:

    sparrow plg search apache
    sparrow plg search nginx
    sparrow plg search ssh
    sparrow plg search mysql

Pattern should be perl regexp pattern. Examples:

* `.*`     # find any   plugin
* `nginx`  # find nginx plugins
* `mysql-` # find mysql plugins

## build / reload sparrow index

Sparrow index is cached data used by sparrow to search plugins.

Index consists of two parts:

* private plugins index , see [SPL file](#spl-file) section for details
* public  plugins index, [PUBLIC PLUGINS](#public-plugins) section for details

There are two basic command to work with index:

* *sparrow index summary*

This command will show timestamps and file locations for public and private index files

*sparrow index update*

This command will fetch fresh index from SparrowHub and update local cached index.

This is very similar to what `cpan index reload` command does.

You need this to get know about any updates, changes on SparrowHub public plugins repository.

See [PUBLIC PLUGINS](#public-plugins) section for details.

## download and install sparrow plugins

*sparrow plg install $plugin\_name*

For example:

    sparrow plg search  nginx        # to get know available nginx* plugins
    sparrow plg install swat-nginx   # to download and install a chosen plugin
    sparrow plg install swat-mongodb-http --version 0.3.7 # install specific version

Check [sparrow-plugins](#sparrow-plugins) section to know more about sparrow plugins.

To see installed plugin list say this:

*sparrow plg list*

To get installed plugin info say this:

*sparrow plg show $plugin\_name*

To remove installed plugin:

*sparrow plg remove $plugin\_name*

For example:

    sparrow plg remove df-check

## create checkpoints

*sparrow check add $project\_name $checkpoint\_name*

* Checkpoints tie together tested web service or application and sparrow plugin

* Checkpoints belong to projects, so to create a checkpoint you need to point a project


Command examples:

    sparrow check production-web-servers nginx
    sparrow check production-web-servers apache
    sparrow check db-servers mysql
    sparrow check my-machine sshd

## setup checkpoints

*sparrow check set $project\_name $checkpoint\_name $plugin_name [$host]*

Once checkpoint is created you need to setup it. 

By setting checkpoint you bind it to a certain plugin:

* plugin\_name

Is a name of plugin to run tests.

* host

This optional parameter sets base url or hostname of a web service or application being tested.

Command examples:

    sparrow check set localhost sshd sshd-check  
    sparrow check set localhost sshd sshd-check 127.0.0.1
    sparrow check set db-servers mysql outth-mysql 127.0.0.1:3306

    sparrow check set cpan-modules kelp swat-kelp 127.0.0.1:3000
    sparrow check set production-web-servers nginx swat-nginx http://my.nginx.host
    sparrow check set db-servers mongo swat-mongodb-http http://localhost:28017
    sparrow check set dev-app my-cool-app swat-my-app http://my.dev.host:5555/foo/bar/baz

To get checkpoint info say this:

*sparrow check show $project\_name $checkpoint\_name*

For example:

    sparrow check show production-web-servers nginx

## run tests

There are two ways to run tests. 

First one is to run tests _via checkpoint interface_ :

*sparrow check run $project\_name $check\_name*

Examples:

    sparrow check run my-machine sshd

    sparrow check run production-web-servers nginx


Second way is simply run tests _via plugin interface_ :
 

*sparrow plg run $plugin\_name*

The 2 tests examples above could be run as plugins tests:

    sparrow plg run sshd-check

    sparrow plg run swat-nginx

* Choose run tests via checkpoint interface when you want to add host settings for test suite.

* Choose run tests via plugin interface when you have no host specific settings for test suite.

_Warning_: you can run only [public plugins](#public-plugins) tests using plugin interface.

## Running tests under cron.

*sparrow check run $project\_name $check\_name --cron*

When running tests under cron mode a normal output suppressed and is emitted only if tests fails.

Example:

    sparrow check run my-machine sshd --cron

## configuring checkpoints

*sparrow check ini $project\_name $checkpoint\_name*

This command configures sparrow plugin binded to checkpoint. There are two formats supported:

* YAML
* .ini 

Sparrow will examine a content of configuration file and try to identify format automatically.

For example for .ini format:

    export EDITOR=nano

    sparrow check ini system disk

        [disk]
        # disk used threshold in %
        threshold = 80

Or yaml format:

    sparrow check ini system disk
    ---
    disk
      threshold: 80
 
More information on ini files syntax could be found here:

* [swat tests ini files](https://github.com/melezhik/swat#swat-ini-files)
* [generic tests ini files](https://github.com/melezhik/outthentic#test-suite-ini-file)

Alternatively you may load plugin ini file from file path

*sparrow check load_ini $project\_name $checkpoint\_name path/to/file*

For example:

    sparrow check load_ini foo foo-app /path/to/ini/file

## run tests remotely

NOT IMPLEMENTED YET.

*GET /$project\_name/check\_run/$project\_name/$checkpoint\_name*

Sparrow rest API allow to run test suites remotely over http. This function is not implemented yet.

    # runs sparrow rest API daemon
    sparrowd

    # runs swat tests via http call
    curl http://127.0.0.1:5090/check_run/db-servers/mysql

## remove checkpoints

*sparrow check remove $project\_name $checkpoint\_name*

Examples:

    # remove checkpoint nginx-check in project foo
    sparrow check remove foo nginx-check

# SPARROW PLUGINS

Sparrow plugins are shareable outthentic test suites installed from remote sources.

There are two type of sparrow plugins:

* public plugins are provided by [SparrowHub](https://sparrowhub.org/) community plugin repository and considered as public access

* private plugins are provided by internal or external git repositories and _not necessary_ considered as public access

Both public and private plugins are installed with help of sparrow client:

    sparrow plg install plugin_name

## PUBLIC PLUGINS

The public plugins features:

* they are kept in a central place called [SparrowHub](https://sparrowhub.org/) - community plugins repository

* they are versioned so you may install various version of a one plugin

 
## PRIVATE PLUGINS

Private plugins are ones created by you and not supposed to be accessed publicly.

The private plugins features:

* they are kept in arbitrary remote git repositories ( public or private ones )

* they are not versioned, a simple \`git clone/pull' command is executed to install/update a plugin

* private plugins should be listed at sparrow plugin list file (SPL file)

### SPL FILE

Sparrow plugin list is represented by text file placed at `\~/sparrow.list'

SPL file should contains lines in the following format:

*$plugin\_name $git\_repo\_url*

Where:

* git\_repo\_url

Is a remote git repository URL

* plugin\_name

A name of your sparrow plugin, could be arbitrary name but see restriction notice concerning public plugin names.

Example entries:

    swat-yars   https://github.com/melezhik/swat-yars.git
    metacpan    https://github.com/CPAN-API/metacpan-monitoring.git

Once you add a proper entries into SPL file you may list and install a private plugins:

    sparrow plg show    swat-yars
    sparrow plg install swat-yars

# CREATING SPARROW PLUGINS

Here is a brief description of the process:

## swat test suite

To get know to create swat tests please follow swat project documentation -
[https://github.com/melezhik/swat](https://github.com/melezhik/swat).

A simplest swat test to check that web service returns \`200 OK' when receive \`GET /' request will be:

    echo 200 OK > get.txt

### create a cpanfile

As sparrow relies on [carton](https://metacpan.org/pod/Carton) to handle perl dependencies you need to create a valid
[cpanfile](https://metacpan.org/pod/cpanfile) in the plugin root directory.

The minimal dependency you have to declare is swat perl module:

    $ cat cpanfile

    require 'swat';


Of course you may also add other dependencies your plugin might need:

    $ cat cpanfile

    require 'HTML::Entities'

### create sparrow.json file

Sparrow.json file describes plugin's meta information required for plugin gets uploaded to SparrowHub.

In case of private plugin you may skip this step.

Create sparrow.json file and place it in plugin root directory:

    {
        "version": "0.1.1",
        "name": "my-cool-plugin",
        "engine": "swat", 
        "description" : "this is a great plugin!",
        "url" : "http://...."
    }

This is the list of obligatory parameters you have to set:

* version - perl version string.

A detailed information concerning version syntax could be find here -
[https://metacpan.org/pod/distribution/version/lib/version.pm](https://metacpan.org/pod/distribution/version/lib/version.pm)

* name - plugin name.

Only symbols \`a-zA-Z1-9_-.' are allowable in plugin name

This the list of optional parameters you may set as well:

* engine 

Defines test framework for test suite. Default value is \`swat'. Other possible value is 'generic', see
[generic test suite section](#generic-test-suite)

* url - an http URL for the site where one could find a detailed plugin information ( docs, source code, issues ... )

* description - a short description of your plugin

### generic test suite

Creation of generic tests is very similar to a swat tests, but you'd better read [outthentic framework documentation](https://github.com/melezhik/outthentic) to 
understand the difference.

Once your test suite is ready prepare the same additional stuff as with swat test suite:

* cpanfile
* sparrow.json

Cpanfile should declare at least a dependency on Outthentic perl module:

    $ cat cpanfile

    require 'Outthentic';

Sparrow.json file does not differ from the one described at [swat test suite](#swat-test-suite) section, except for
\`engine' field value:

    {
        "engine": "generic"
    }

# PUBLISHING SPARROW PLUGINS

## Private plugin

All you need is to keep a plugin source code in the remote git repository.

Plugin root directory should be repository root directory.

Once a plugin is placed at git remote repository you need to add a proper entry into SPL file, see [SPL FILE](#) section how to do this.

## Public plugin

To publish you plugin into SparrowHub you need:

* Get registered at SparrowHub

Go to [https://sparrowhub.org](https://sparrowhub.org)

* Get rest api token

Login into your account. Go on "Profile" page, then on "My Token" page and then hit "Regenerate Token" link.

Once your get you token, setup a sparrowhub credentials on the machine where your are going upload plugin from:

    cat ~/sparrowhub.json

    {
        "user"  : "melezhik",
        "token" : "ADB4F4DC-9F3B-11E5-B394-D4E152C9AB83"
    }


* Upload plugin

    * Check if you have sparrowhub credentials setup correctly ( previous step ) on your machine
    * Install sparrow client on your machine
    * Then go to directory where your plugin source code at and say \`sparrow plg upload'. That's it

For example:

    $ cd plugin_root_directory
    $ sparrow plg upload

Another way to supply sparrow with valid SparrowHub credentials - use `sph_user` and `sph_token` environment variables.
Probably useful in automation scripts:

    $ sph_user=melezhik sph_token=ADB4F4DC-9F3B-11E5-B394-D4E152C9AB83 sparrow plg upload
    

# AUTHOR

[Aleksei Melezhik](mailto:melezhik@gmail.com)

# Home page

https://github.com/melezhik/sparrow

# COPYRIGHT

Copyright 2015 Alexey Melezhik.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.


# THANKS

* to God as - *For the LORD giveth wisdom: out of his mouth cometh knowledge and understanding. (Proverbs 2:6)*




