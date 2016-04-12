# NAME

Sparrow

[![Build Status](https://travis-ci.org/melezhik/sparrow.svg)](https://travis-ci.org/melezhik/sparrow)
 
# SYNOPSIS

Sparrow - outthentic plugins manager.  Manages outthentic family suites.

# CAVEAT

The project is still in very alpha stage. Things might change. But you can start play with it :-)


# Install

    $ sudo yum install git
    $ sudo yum install curl # skip this if you are not going to use private sparrow plugins
    $ cpanm Sparrow

# Glossary 

## Outthentic DSL

Outthentic is a word combined from two parts - \`out' and \`authentic', meaning that a program prints something into stdout and
and someone prove program authenticity (correctness) by matching output for some rules defined in terms of Outthentic DSL - 
is a language to verify, analyze unstructured text output.

Follow [Outthentic DSL](https://github.com/melezhik/outthentic-dsl) to for details.

## Outthentic suites

Outthentic suites are small scenarios based on Outthentic DSL to provide solutions
for various testing, monitoring, reporting tasks from checking available disk space
to ensuring that your web server is healthy.
 
There are 2 type of outthentic suites - swat and generic. Read further.

## Sparrow plugins

Sparrow plugins are shareable outthentic suites distributed via outthentic suites repository - [SparrowHub](https://sparrowhub.org).
Term plugins refers to the idea of different outthentic suites could be pluggable and so get used on single machine
via a unified interface of sparrow console client. It is very close to the conception of CPAN modules in Perl or ruby gems in Ruby.


## SparrowHub

SparrowHub is a [central repository](https://sparrowhub.org) of sparrow plugins. 

## Sparrow tool

`sparrow` is a console client to search, install, setup and finally run various sparrow plugins.
Think about it as of cpan client for CPAN modules or gem client for ruby gems.

## Two types of sparrow plugins

There are tow types of outthentic suites or sparrow plugins:

* Swat test suites

* Generic suites

## Swat test suites

Are those based on [swat](https://github.com/melezhik/swat) web application testing framework.
Swat is in turn based on Outthentic DSL. Swat test suites are dedicated to web application testing.

## Generic suites

Are those based on [outthentic](https://github.com/melezhik/outthentic) - generic purposes testing / monitoring framework.
Outthentic framework is in turn based in Outthentic DSL. 

Generic suites unlike swat test suites is _generic purposes_ suites for various tasks, like
monitoring processes in process list or investigating log entries. 

# Sparrow basic entities

Basically user deal with 3 type of entities:

## Plugins

A sparrow plugins which you search, install, configure and run. As already told, usually plugin is a small
testing, monitoring, reporting suite to solve a specific issue. For example check available disk space or
ensure that service is running. There are a plenty of plugins at SparrowHub.

## Checkpoints 

Checkpoint is configurable sparrow plugin. Some plugins does not require configuration and could be run as is,
but many ones require some piece of input data. For example hostname of application being checked or supplimental parameters
to adjust plugin logic. Thus, checkpoint is a container for:

* plugin
* plugin configuration

Plugin configuration is just a text file in one of 2 formats:

* .ini style format
* YAML format

Plugin configuration will be explain latter.

## Projects

Projects are logic groups of sparrow checkpoints. It's convenient to split a whole list of checkpoint to
different logical groups. Like one for system checks - disk available space or RAM status, other
for web servers status, so on. 

# API

Now having a knowledges about basic sparrow entities let's dive  into sparrow API provided by `sparrow`
console client.

## Projects API

Sparrow project is a logical group of sparrow checkpoints. To create a project use `sparrow project create` command:

*sparrow project create $project\_name*

Command examples:

    # system level checks
    $ sparrow project create system

    # web servers checks
    $ sparrow project create web-servers

To get project information say this:

*sparrow project show $project\_name*

For example:

    $ sparrow project show system

To get all projects list say this:

*sparrow project list*

To remove project data say this:

*sparrow project remove $project\_name*

For example:

    $ sparrow project web-servers remove

Note - this command will remove all checkpoints related to project as well!

## Search plugins API

Sparrow plugin is a shareable outthentic suite.

One could install sparrow plugin and then run related outthentic scenarios, see [check](#running-suites) action for details.

To search available plugins use `sparrow plg search` command:

*sparrow plg search $pattern*

For example:

    # list all available plugins
    $ sparrow plg search 
  
    # find foo-* plugins
    $ sparrow plg search foo

Search pattern should be perl regular expression. Examples:

* `.*`     # find any   plugin
* `nginx`  # find nginx plugins
* `mysql-` # find mysql plugins

## Sparrow index API

Sparrow index is cached data used by sparrow to search plugins.

Index consists of two parts:

* private plugins index , see [SPL file](#spl-file) section for details
* public  plugins index, [PUBLIC PLUGINS](#public-plugins) section for details

There are two basic command to work with index:

* *sparrow index summary*

This command will show timestamps and file locations for public and private index files.

*sparrow index update*

This command will fetch fresh index from SparrowHub and update local cached index.

This is very similar to what `cpan index reload` command does.

You need `sparrow index update` to get know about updates, changes of SparrowHub repository. For example
when someone release new version of plugin.

See [public plugins](#public-plugins) section for details on sparrow public plugins and SparrowHub.

## Installing sparrow plugins

*sparrow plg install $plugin\_name*

For example:

    $ sparrow plg search  nginx        # to get know available nginx* plugins
    $ sparrow plg install nginx-check  # to download and install a chosen plugin
    $ sparrow plg install swat-mongodb-http --version 0.3.7 # install specific version

Check [sparrow-plugins](#sparrow-plugins) section to know more about sparrow plugins.

To see installed plugin list say this:

*sparrow plg list*

To get installed plugin information say this:

*sparrow plg show $plugin\_name*

To remove installed plugin use `sparrow plg remove` command:

*sparrow plg remove $plugin\_name*

For example:

    $ sparrow plg remove df-check

## Checkpoints API

To create a checkpoint use `sparrow check add` command:

*sparrow check add $project\_name $checkpoint\_name*

Checkpoints are parts of projects, so to create a checkpoint you always have to point a project.

Command examples:

    $ sparrow check add web-servers nginx
    $ sparrow check add system disk

## Setup checkpoints

By setting checkpoint you:

*  bind checkpoint to sparrow plugin
* (optionally) set hostname parameter for sparrow plugin

`sparrow check set` command is used to set checkpoint:

*sparrow check set $project\_name $checkpoint\_name $plugin_name [$hostname]*

Hostname is optional parameter to set base url or hostname of a web service or application being tested.

Command examples:

    # bind nginx checkpoint to swat-nginx plugin
    sparrow check set webservers nginx swat-nginx  

    # bind nginx checkpoint to swat-nginx plugin, explicitly sets hostname to 127.0.0.1
    sparrow check set webservers nginx swat-nginx 127.0.0.1

    # the same as above but for remote nginx server, hostname 192.168.0.1
    sparrow check set webservers nginx-remote swat-nginx  192.168.0.1

    # bind mysql-server to outth-mysql plugin and sets mysql server address
    sparrow check set db-servers mysql-server outth-mysql 127.0.0.1:3306

    # bind mongo checkpoint to swat-mongodb-http plugin and sets mongodb http API URL
    sparrow check set db-servers mongo swat-mongodb-http http://my.server:28017/mongoAPI


## Running suites

There are two ways to run outthentic suites:

First one is to run suite _via checkpoint interface_:

*sparrow check run $project\_name $check\_name*

For example:

    $ sparrow check run system disk


Second way is simply run tests _via plugin interface_, in this case you do not need a checkpoint at all
to run a suite, because you run it as is. The back side of this approach you rely on _default_ plugin configuration and can't
define your own one:
 
*sparrow plg run $plugin\_name*

    $ sparrow plg run df-check # this suite will run with default values for disk.threshold parameter

* Choose checkpoint interface when you want to add some specific settings for outthentic suite.

* Choose plugin interface when you have no host specific settings for suite and default settings are just enough for you.
Notice that many sparrow plugins still require a specific configuration and can't be run  this way.

* Only [public plugins](#public-plugins) could be run using plugin interface.

## Running suites with cron

When running suite under cron it is handy only have an output if something goes wrong, f.e.
test suite failed or something else goes bad. Use `--cron` flag to enable this behavior:

*sparrow check run $project\_name $check\_name --cron*

Running checkpoint with --cron flag suppress a normal output and only emit something in case of failures.

Example:

    $ sparrow check system disk --cron # pleas keep quite if disk space is ok

## Configuring checkpoints

Checkpoint configuration is a configuration data consumed by plugin binded to checkpoint. 
One have to consult plugin documentation ( for public plugins - this is SparrowHub site ) to get know
the structure of configuration data to feed.

Sparrow support two configuration formats:

* .ini 
* YAML

.Ini style format is _default_ format for checkpoint configuration. 

Use `check ini` command to set checkpoint configuration:

*sparrow check ini $project\_name $checkpoint\_name*

For example:

    $ export EDITOR=nano

    $ sparrow check ini system disk

        [disk]
        # disk used threshold in %
        threshold = 80

Having this sparrow will save plugin configuration in the file related to checkpoint and will use it during
checkpoint run:

    $ sparrow check run system disk # the value of disk.threshold is 80

User also could copy existed configuration from file using `check load_ini` command:

*sparrow check load_ini $project\_name $checkpoint\_name /path/to/ini/file*

For example:

    $ sparrow check load_ini system disk /etc/plugins/disk.ini

To get checkpoint configuration use `sparrow check show` command:

*sparrow check show $project\_name $checkpoint\_name*

For example:

    $ sparrow check show webservers nginx

Alternative way to configure sparrow checkpoint is to load configuration from yaml file _during_ checkpoint [run](#running-suites):

    $ cat disk.yml

    ---
    disk
      threshold: 80

    $ sparrow check run system disk --yml disk.yml
     
While `sparrow check ini/load_ini` command saves checkpoint configuration and makes it persistent,
`sparrow check run --yml` command applies checkpoint configuration only for suite run and could be treated
as runtime configuration. 

For common usage, when user runs checkpoints manually first approach is more
convenient, while second one is a _way automatic_, when checkpoints configurations are kept as yaml files
and maintained out of sparrow scope ( f.e. by other configuration management tools ) and thus further applied
during checkpoint run.
 
More information on outthentic suites configurations could be found here:

* [swat suites configuration files](https://github.com/melezhik/swat#swat-ini-files)
* [generic suites configuration files](https://github.com/melezhik/outthentic#test-suite-ini-file)

## Removing checkpoints

Use this command to remove checkpoint data from project container:

*sparrow check remove $project\_name $checkpoint\_name*

Examples:

    # remove checkpoint nginx from project web-servers
    $ sparrow check remove web-servers nginx

# Sparrow plugins

Sparrow plugins are shareable outthentic suites installed from remote sources.

There are two type of sparrow plugins:

* public plugins are provided by [SparrowHub](https://sparrowhub.org/) community plugin repository and considered as public access.

* private plugins are provided by internal or external git repositories and _not necessary_ considered as public access.

Both public and private plugins are installed with help of sparrow client:

*sparrow plg install plugin_name*

## Public plugins

The public plugins features:

* they are kept in a central place called [SparrowHub](https://sparrowhub.org/) - community plugins repository.

* they are versioned so you may install various version of a one plugin.

 
## Private plugins

Private plugins are ones created by you and not supposed to be accessed publicly.

The private plugins features:

* they are kept in arbitrary remote git repositories ( public or private ones )

* they are not versioned, a simple \`git clone/pull' command is executed to install/update a plugin

* private plugins should be listed at sparrow plugin list file (SPL file)

### SPL file

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

    $ sparrow plg show    swat-yars
    $ sparrow plg install swat-yars

# Create sparrow plugin

Here is a brief description of the process:

## Swat test suites

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

Defines framework for suite. Default value is \`swat'. Other possible value is 'generic', see
[generic suites section](#generic-suites)

* url - an http URL for the site where one could find a detailed plugin information ( docs, source code, issues ... )

* description - a short description of your plugin

### Generic suites

Creation of generic suites is very similar to a swat test suites, but you'd better read [outthentic framework documentation](https://github.com/melezhik/outthentic) to 
understand the difference.

Once your suite is ready add the same metadata as with swat test suite:

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

# Publishing sparrow plugins

## Private plugin

* All you need is to keep a plugin source code in the remote git repository.

* Plugin root directory should be repository root directory.

* Once a plugin is placed at git remote repository you need to add a proper entry into SPL file, see [SPL FILE](#) section how to do this.

## Public plugin

To publish you plugin into SparrowHub you need:

* Get registered at SparrowHub

Go to [https://sparrowhub.org](https://sparrowhub.org)

* Get rest api token

Login into your account. Go on "Profile" page, then on "My Token" page and then hit "Regenerate Token" link.

Once your get you token, setup a sparrowhub credentials on the machine where your are going upload plugin from:

    $ cat ~/sparrowhub.json

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

# Copyright

Copyright 2015 Alexey Melezhik.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.


# Thanks

* to God as - *For the LORD giveth wisdom: out of his mouth cometh knowledge and understanding. (Proverbs 2:6)*




