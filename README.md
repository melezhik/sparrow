# NAME

Sparrow

[![Build Status](https://travis-ci.org/melezhik/sparrow.svg)](https://travis-ci.org/melezhik/sparrow)
 
# SYNOPSIS

Sparrow - multipurposes scenarios manager.

# CAVEAT

The project is still in very alpha stage. Things might change. But you can start play with it :-)


# Install

    $ sudo yum install git # only required for installing private plugins
    $ sudo yum install curl
    $ cpanm Sparrow

# Sparrow plugins

Sparrow plugins are shareable multipurposes scenarios distributed via central repository - [SparrowHub](https://sparrowhub.org).
Every single plugin represents a various scripts to solve a specific task. Plugins are easily installed, configured and run on
dedicated servers with the help of sparrow console client. 

The notion of sparrow plugins is very close to the conception of CPAN modules in Perl or Ruby gems in Ruby.
It's just a small suites of scripts to solve a specific tasks.

To find a specific sparrow plugin say this:

    $ sparrow plg search nginx


To install a sparrow plugin say this: 

    $ sparrow plg install nginx-check

See [sparrow command line API](#api) below.
 
# Sparrow client

`Sparrow` is a console client to search, install, setup and run various sparrow plugins. 
Think about it as of `cpan client` for CPAN modules or `gem client` for Ruby gems.

# Sparrow basic entities

Sparrow architecture comprises of 4 basic parts:

* Plugins
* Tasks
* Projects
* Task Boxes


# Tasks

_Task_ is configurable sparrow plugin. Some plugins does not require configuration and could be run as is,
but many ones require some piece of input data. Thus sparrow task is a container for:

* plugin
* plugin configuration

Plugin configuration is just a text file in one of 2 formats:

* [Config::General](https://metacpan.org/pod/Config::General) format
* YAML format

# Projects

Projects are _logical groups_ of sparrow tasks. It is convenient to split a whole list of tasks to different logical groups. 
Like some tasks for system related issues - f.e. checking [disk available space](https://sparrowhub.org/info/df-check) or inspecting [stale processes](https://sparrowhub.org/info/stale-proc-check), other tasks for
web services related issues - f.e. [checking nginx health](https://sparrowhub.org/info/nginx-check) or [monitoring http errors](https://sparrowhub.org/info/logdog) in web server logs, so on. 

# Task Boxes

Sparrow tasks boxes are YAML format files to describe sequential tasks to run. You could think about sparrow boxes as of multi tasks -
tasks run sequentially.

WARNIGN! This feature is not implemented yet.

# API

This is a sparrow command line API documentation.

## Projects API

Sparrow project is a logical group of sparrow tasks. To create a project use `sparrow project create` command:

**sparrow project create $project\_name**

Command examples:

    # system level tasks
    $ sparrow project create system

    # web servers related tasks
    $ sparrow project create web-servers

To get project information say this:

**sparrow project show $project\_name**

For example:

    $ sparrow project show system

To get projects list say this:

**sparrow project list**

To remove project data say this:

**sparrow project remove $project\_name**

For example:

    $ sparrow project web-servers remove

NOTE! This command will remove all project tasks as well!

## Plugins API

To search available plugins use `sparrow plg search` command:

**sparrow plg search $pattern**

Where $pattern is Perl regular expression pattern.

Examples:

  
    # find ssh-* plugins
    $ sparrow plg search ssh

    [found sparrow plugins]
    
    type    name
    
    public  ssh-sudo-check
    public  ssh-sudo-try
    public  sshd-check
    
    # find package managers plugins
    $ sparrow plg search package

    [found sparrow plugins]
    
    type    name
    
    public  package-generic
    

To list all available plugins say this:

    $ sparrow plg search 

### Index API

Sparrow index is cached data used by sparrow to search plugins.

Index consists of two parts:

* private plugins index , see [SPL file](#spl-file) section for details
* public  plugins index, [PUBLIC PLUGINS](#public-plugins) section for details

There are two basic command to work with index:

* **sparrow index summary**

This command will show timestamps and file locations for public and private index files.

* **sparrow index update**

This command will fetch fresh index from SparrowHub and update local cached index.

This is very similar to what `cpan index reload` command does.

You need `sparrow index update` to get know about updates, changes of SparrowHub repository. For example
when someone release new version of plugin.

See [public plugins](#public-plugins) section for details on sparrow public plugins and SparrowHub.

### Installing sparrow plugins

**sparrow plg install $plugin\_name**

For example:

    $ sparrow plg search  nginx        # to get know available nginx* plugins
    $ sparrow plg install nginx-check  # to download and install a chosen plugin
    $ sparrow plg install nginx-check --version 0.1.1 # install specific version

To see installed plugin list say this:

    $ sparrow plg list

To get installed plugin information say this:

**sparrow plg show $plugin\_name**

To remove plugin installed use `sparrow plg remove` command:

**sparrow plg remove $plugin\_name**

For example:

    $ sparrow plg remove df-check

## Tasks API

### Create tasks

To create a task use `sparrow task add` command:

**sparrow check add $project\_name $task\_name $plugin\_name**

Tasks always belong to projects, so to create a task you have to create a project first if not exists.
Tasks binds a plugin with configuration, so to create a task you have to install a plugin first.

Command examples:

    $ sparrow project create system
    $ sparrow plg install df-check
    $ sparrow task add system disk-health df-check


### Run plugins

There are two ways to run sparrow plugins:

* as\_is

* as tasks

The first one is simplest as it does not require creating a task at all. If you don't want provide a specific plugin configuration,
you may run a plugin as is using  `sparrow plg run` command:


**sparrow plg run [ options ]**

For example:

    $ sparrow plg run df-check

NOTE! Only [public plugins](#public-plugins) could be run _as\_is_.

The second way requires task creation and benefits in applying specific configuration for a plugin:

**sparrow task run $project\_name $check\_name [ options ]**

For example:

    $ sparrow check run system disk-health

See [configuring tasks](#configuring-tasks) section on how one can configure task plugin.

### Setting runtime parameters 

It is possible to pass _whatever_ runtime configuration parameters when running tasks or plugins:


    $ sparrow plg run df-check --param threshold=60

    $ sparrow check run system disk-health --param threshold=60

Runtime parameters override default parameters ones set in tasks configurations, see [configuring tasks](#configuring-task) section.

### Setting outthentic parameters

As sparrow runs plugins with the help of [Outthentic scenarios runner](https://github.com/melezhik/outthentic#options) it accepts all
_runner related_ parameters, check out [Outthentic](https://github.com/melezhik/outthentic#options) for details. Other parameters examples:


    $ sparrow check run system disk-health --verbose
    $ sparrow check run system disk-health --verbose --prove '-Q'


### Running tasks with cron

When running tasks with cron it is handy only have an output if something goes wrong, 
f.e. if plugin failed for some reasons. Use `--cron` flag to enable this behavior:

**sparrow check run $project\_name $check\_name --cron**

Running checkpoint with --cron flag suppress a normal output and only emit something in case of failures.

Example:

    $ sparrow check system disk-health --cron # pleas keep quite if disk space is ok

### Configuring tasks

Task configuration is a some input parameters consumed by plugin binded to task. 
User should consult plugin documentation to get know a certain structure of configuration data to feed.

Sparrow supports two configuration formats:

* Config::General 
* YAML

Config::General format is _default_ format for task configuration.  Use `task ini` command to set task configuration:

**sparrow task ini $project\_name $checkpoint\_name**

For example:

    $ export EDITOR=nano

    $ sparrow check ini system disk-health

    # disk used threshold in %
    threshold = 80

Having this sparrow will save plugin configuration in the file related to task and will use it during task run:

    $ sparrow task run system disk-health # the value of threshold is 80

User could copy existed configuration from file using `check load_ini` command:

**sparrow task load_ini $project\_name $checkpoint\_name /path/to/ini/file**

For example:

    $ sparrow task load_ini system disk-health /etc/plugins/disk.ini

To get task configuration use `sparrow task show` command:

**sparrow task show $project\_name $checkpoint\_name**

For example:

    $ sparrow task show system disk-health


Alternative way to configure sparrow checkpoint is to load configuration from yaml file _during_ checkpoint [run](#running-suites):

    $ cat disk.yml

    ---
    threshold: 80

    $ sparrow check run system disk --yaml disk.yml
     
While `sparrow task ini/load_ini` command saves checkpoint configuration and makes it persistent,
`sparrow task run --yaml` command applies plugin configuration only for runtime and won't save it after plugin execution.

For common usage, when user runs tasks manually first approach is more convenient, 
while the second one is a _way automatic_, when tasks configurations are kept as yaml files
and maintained out of sparrow scope and applied during task run.
 
### Removing tasks

Use this command to remove task from the project container:

**sparrow task remove $project\_name $checkpoint\_name**

Examples:

    # remove task disk-health project system
    $ sparrow check remove system disk-health

# Sparrow plugins

Sparrow plugins are shareable multipurposes scenarios installed from remote sources.

There are two type of sparrow plugins:

* public plugins are provided by [SparrowHub](https://sparrowhub.org/) community repository and considered as public access.

* private plugins are provided by internal or external git repositories and _not necessary_ considered as public access.

Both public and private plugins are installed with help of sparrow client:

**sparrow plg install plugin_name**

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

    package-generic   https://github.com/melezhik/package-generic.git

Once you add a proper entries into SPL file you may list and install a private plugins:

    $ sparrow plg show package-generic

# Publishing public sparrow plugin to SparrowHub

On how to create a sparrow plugins please follow [Outthentic documentation](https://github.com/melezhik/outthentic).

Once a plugin is create you should do 4 simple steps:

* get registered on SparrowHub and create a token
* setup sparrowhub.json file
* create a plugin meta file - sparrow.json
* upload a plugin with the help of `sparrow plg upload` command

## Get registered on SparrowHub

Go to [https://sparrowhub.org/sign_up](https://sparrowhub.org/sign_up) and create an account

## Generate a token

Login into SparrowHub, go to Profile page and hit "Regenerate Token" on  [https://sparrowhub.org/token](https://sparrowhub.org/token)  page.

## Setup sparrowhub.json

Once your get you token, setup a sparrowhub credentials on the machine where you are going upload plugin from:

    $ cat ~/sparrowhub.json

    {
        "user"  : "melezhik",
        "token" : "ADB4F4DC-9F3B-11E5-B394-D4E152C9AB83"
    }

NOTE! Another way to provide SparrowHub credentials is to set `$sph_user` and `$sph_token` environment variables:

    $ export sph_user=melezhik 
    $ export sph_token=ADB4F4DC-9F3B-11E5-B394-D4E152C9AB83


## Create a plugin meta file sparrow.json

Sparrow.json file holds plugin  meta information required for plugin gets uploaded to SparrowHub.

Create sparrow.json file and place it in a plugin root directory:

    {
        "version": "0.1.1",
        "name": "df-check",
        "description" : "elementary file system checks using df utility report ",
        "url" : "https://github.com/melezhik/df-check"
    }

This is the list of obligatory parameters you have to set:

* version - perl version string.

A detailed information concerning version syntax could be find here -
[https://metacpan.org/pod/distribution/version/lib/version.pm](https://metacpan.org/pod/distribution/version/lib/version.pm)

* name - plugin name.

Only symbols \`a-zA-Z1-9_-.' are allowable in plugin name

This the list of optional parameters you may set as well:

* url - an http URL for the site where one could find a detailed plugin information ( docs, source code, issues ... )

* description - a short description of your plugin

## Upload plugin

* Install sparrow client on your machine
    
    $ cpanm Sparrow
    
* Go to directory where your plugin source code at and say:
    
    $ sparrow plg upload
    
That's it!

# Publishing private sparrow plugins

The process is almost the same as for public plugins, except you don't have to provide SparrowHub credentials
and gets registered as you host your plugin at remote git repository. 

You have to do 3 simple steps:

* create a plugin and commit it into local git repository, plugin root directory should be repository root directory
* create plugin meta file - sparrow.json and commit it into local git repository ( sparrow.json file is the same as for public plugins )
* push your changes into remote git repository

# Declaring dependencies

This is the way how one can declare dependencies for sparrow plugins:

    +----------+----------+
    | Language |  File    |
    +----------+----------+
    | Perl     | cpanfile |
    | Ruby     | Gemfile  |
    +----------+----------+

You should place a dependency file into a plugin root directory.

 
# AUTHOR

[Aleksei Melezhik](mailto:melezhik@gmail.com)

# Home page

[https://github.com/melezhik/sparrow](https://github.com/melezhik/sparrow)

# Copyright

Copyright 2015 Alexey Melezhik.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

# See also

* [Outthentic](https://github.com/melezhik/outthentic) - Multipurposes scenarios framework.

# Thanks

To God as the One Who inspires me to do my job!





