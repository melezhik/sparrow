# NAME

Sparrow

[![Build Status](https://travis-ci.org/melezhik/nginx-swat-test.svg)](https://travis-ci.org/melezhik/sparrow)
 
# SYNOPSIS

Sparrow - [swat](https://github.com/melezhik/swat) based monitoring tool.
  
# CAVEAT

The project is still in very alpha stage. Things might change. But you can start play with it :-)


# FEATURES

* console client to setup and run swat test suites
* installs and runs sparrow plugins - shareable swat test suites
* ability to run tests remotely over rest API (TODO)

# DEPENDENCIES

git, curl, bash

# INSTALL

    sudo yum install git
    sudo yum install curl

    cpanm Sparrow

# USAGE

These are actions provided by sparrow console client:

## create a project

*sparrow project create $project\_name*

Create a sparrow project.

Sparrow project is a container for swat test suites and tested web services.

Sparrow project is entry point where one run swat tests against different applications.

Example command:

    sparrow project create foo

To get project info say this:

*sparrow project show $project\_name*

For example:

    sparrow project show foo

To see projects list say this:

*sparrow project list*

To remove project data say this:

*sparrow project remove $project\_name*

For example:

    sparrow project foo remove

## search sparrow plugins

Sparrow plugin is a shareable swat test suite.

One could install sparrow plugin and then run related swat tests, see [check](#run-swat-tests) action for details.

To search available plugins say this:

*sparrow plg search $pattern*

For example:

    sparrow plg search nginx

Pattern should be perl regexp pattern. Examples:

* `.*`    # find any   plugin
* `nginx` # find nginx plugins
* `kelp-` # find kelp  plugins

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

    sparrow plg search nginx # to get know available nginx* plugins
    sparrow plg install swat-nginx # to download and install a chosen plugin
    sparrow plg install swat-mongodb-http --version 0.3.7 # install specific version

Check [sparrow-plugins](#sparrow-plugins) section to know more about sparrow plugins.

To see installed plugin list say this:

*sparrow plg list*

To get installed plugin info say this:

*sparrow plg show $plugin\_name*

To remove installed plugin:

*sparrow plg remove $plugin\_name*

For example:

    sparrow plg remove swat-kelp

## create checkpoints

*sparrow check add $project\_name $checkpoint\_name*

* Checkpoints tie together tested web service and sparrow plugin

* Checkpoints belong to projects, so to create a checkpoint you need to point a project


Command examples:

    sparrow check foo nginx-check
    sparrow check foo tomcat-app-check

## setup checkpoints

*sparrow check set $project\_name $checkpoint\_name $args*

Once checkpoint is created you need to setup it. Setting checkpoint means providing 2 obligatory parameters:

* -p plugin\_name
* -u base\_url

A plugin name sets a sparrow plugin to run swat test suite from.

A base url sets a web service root URL to send http requests provided by test suite.

Base url be set in [curl compliant](http://curl.haxx.se/docs/manpage.html).

Command examples:

    sparrow check set foo kelp-check -p swat-kelp -u 127.0.0.1:3000
    sparrow check set foo nginx-check -p swat-nginx -u http://my.nginx.host
    sparrow check set foo mongo-app-check -p swat-mongodb-http  -u http://localhost:28017
    sparrow check set foo my-app-check -p swat-my-app -u http://my.nginx.host:5555/foo/bar/baz

To get checkpoint info say this:

*sparrow check show $project\_name $checkpoint\_name*

For example:

    sparrow check show foo nginx-check

## run swat tests

*sparrow check run $project\_name $checkpoint\_name*

Once sparrow project is configured and has some checkpoints you may run swat tests:

Examples:

    sparrow check run foo nginx-check

    sparrow check run foo tomcat-app-check


Use option --cron to run swat tests in \`cron' mode - if tests succeeds not output will be given,
if tests fails a normal output will be yieled as if you run without this option. 

Example:

    sparrow check run foo nginx-app-check --cron

## customize swat settings for checkpoint

*sparrow check set_swat $project\_name $checkpoint\_name *

This command setups [swat ini file](https://github.com/melezhik/swat#swat-ini-files) for swat test suite provided by plugin.

    export EDITOR=nano
    sparrow check set_swat foo nginx-app

        port=88
        prove_options='-sq'

More information on swat ini files syntax could be found here - [https://github.com/melezhik/swat#swat-ini-files](https://github.com/melezhik/swat#swat-ini-files)

## run swat tests remotely

NOT IMPLEMENTED YET.

*GET /$project\_name/check\_run/$project\_name/$checkpoint\_name*

Sparrow rest API allow to run swat test suites remotely over http. This function is not implemented yet.

    # runs sparrow rest API daemon
    sparrowd

    # runs swat tests via http call
    curl http://127.0.0.1:5090/check_run/foo/nginx-app

## remove checkpoints

*sparrow check remove $project\_name $checkpoint\_name*

Examples:

    # remove checkpoint nginx-check in project foo
    sparrow check remove foo nginx-check

# SPARROW PLUGINS

Sparrow plugins are shareable swat test suites installed from remote sources.

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

    sparrow plg info    swat-yars
    sparrow plg install swat-yars

# CREATING SPARROW PLUGINS

Here is a brief description of the process:

## create swat test suite

To get know to create swat tests please follow swat project documentation -
[https://github.com/melezhik/swat](https://github.com/melezhik/swat).

A simplest swat test to check that web service returns \`200 OK' when receive \`GET /' request will be:

    echo 200 OK > get.txt


## create a cpanfile

As sparrow relies on [carton](https://metacpan.org/pod/Carton) to handle perl dependencies you need to create a valid
[cpafile](https://metacpan.org/pod/cpanfile) in the plugin root directory.

The minimal dependency you have to declare is swat perl module:

    $ cat cpanfile

    require 'swat';


Of course you may also add other dependencies your plugin might need:

    $ cat cpanfile

    require 'HTML::Entities'

## create sparrow.json file

Sparrow.json file describes plugin's meta information required for plugin gets uploaded to SparrowHub.

In case of private plugin you may skip this step.

Create sparrow.json file and place it in plugin root directory:

    {
        "version" => "0.1.1",
        "name" => "my-cool-plugin",
        "description" => "this is a great plugin!",
        "url" => "http://...."
    }

This is the list of obligatory parameter you have to set:

* version - perl version string.

A detailed information concerning version syntax could be find here -
[https://metacpan.org/pod/distribution/version/lib/version.pm](https://metacpan.org/pod/distribution/version/lib/version.pm)

* name - plugin name.

Only symbols \`a-zA-Z1-9_-.' are allowable in plugin name

This the list of optional parameters you may set as well:

* url - an http URL for the site where one could find a detailed plugin information ( docs, source code, issues ... )
* description - a short description of your plugin


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




