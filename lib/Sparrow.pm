package Sparrow;

our $VERSION = '0.1.3';

1;

__END__

=pod


=encoding utf8


=head1 NAME

Sparrow

L<![Build Status](https://travis-ci.org/melezhik/sparrow.svg)|https://travis-ci.org/melezhik/sparrow>


=head1 SYNOPSIS

Sparrow - multipurposes scenarios manager.


=head1 CAVEAT

The project is still in very alpha stage. Things might change. But you can start play with it :-)


=head1 Install

    $ sudo yum install git # only required for installing private plugins
    $ sudo yum install curl
    $ cpanm Sparrow


=head1 Sparrow plugins

Sparrow plugins are shareable multipurposes scenarios distributed via central repository - L<SparrowHub|https://sparrowhub.org>.
Every single plugin represents a various scripts to solve a specific task. Plugins are easily installed, configured and run on
dedicated servers with the help of sparrow console client. 

The notion of sparrow plugins is very close to the conception of CPAN modules in Perl or Ruby gems in Ruby.
It's just a small suites of scripts to solve a specific tasks.

To find a specific sparrow plugin say this:

    $ sparrow plg search nginx

To install a sparrow plugin say this: 

    $ sparrow plg install nginx-check

See L<sparrow command line API|#api> below.


=head1 Sparrow client

C<Sparrow> is a console client to search, install, setup and run various sparrow plugins. 
Think about it as of C<cpan client> for CPAN modules or C<gem client> for Ruby gems.


=head1 Sparrow basic entities

Sparrow architecture comprises of 4 basic parts:

=over

=item *

Plugins


=item *

Tasks


=item *

Projects


=item *

Task Boxes


=back


=head1 Tasks

I<Task> is configurable sparrow plugin. Some plugins does not require configuration and could be run as is,
but many ones require some piece of input data. Thus sparrow task is a container for:

=over

=item *

plugin


=item *

plugin configuration


=back

Plugin configuration is just a text file in one of 2 formats:

=over

=item *

L<Config::General|https://metacpan.org/pod/Config::General> format


=item *

YAML format


=back


=head1 Projects

Projects are I<logical groups> of sparrow tasks. It is convenient to split a whole list of tasks to different logical groups. 
Like some tasks for system related issues - f.e. checking L<disk available space|https://sparrowhub.org/info/df-check> or inspecting L<stale processes|https://sparrowhub.org/info/stale-proc-check>, other tasks for
web services related issues - f.e. L<checking nginx health|https://sparrowhub.org/info/nginx-check> or L<monitoring http errors|https://sparrowhub.org/info/logdog> in web server logs, so on. 


=head1 Task Boxes

Sparrow tasks boxes are YAML format files to describe sequential tasks to run. You could think about sparrow boxes as of multi tasks -
tasks run sequentially.

WARNING! This feature is not implemented yet.


=head1 API

This is a sparrow command line API documentation.


=head2 Projects API

Sparrow project is a logical group of sparrow tasks. To create a project use C<sparrow project create> command:

B<sparrow project create $project_name>

Command examples:

    # system level tasks
    $ sparrow project create system
    
    # web servers related tasks
    $ sparrow project create web-servers

To get project information say this:

B<sparrow project show $project_name>

For example:

    $ sparrow project show system

To get projects list say this:

B<sparrow project list>

To remove project data say this:

B<sparrow project remove $project_name>

For example:

    $ sparrow project web-servers remove

NOTE! This command will remove all project tasks as well!


=head2 Plugins API

To search available plugins use C<sparrow plg search> command:

B<sparrow plg search $pattern>

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


=head3 Index API

Sparrow index is cached data used by sparrow to search plugins.

Index consists of two parts:

=over

=item *

private plugins index , see L<SPL file|#spl-file> section for details


=item *

public  plugins index, L<PUBLIC PLUGINS|#public-plugins> section for details


=back

There are two basic command to work with index:

=over

=item *

B<sparrow index summary>


=back

This command will show timestamps and file locations for public and private index files.

=over

=item *

B<sparrow index update>


=back

This command will fetch fresh index from SparrowHub and update local cached index.

This is very similar to what C<cpan index reload> command does.

You need C<sparrow index update> to get know about updates, changes of SparrowHub repository. For example
when someone release new version of plugin.

See L<public plugins|#public-plugins> section for details on sparrow public plugins and SparrowHub.


=head3 Installing sparrow plugins

B<sparrow plg install $plugin_name>

For example:

    $ sparrow plg search  nginx        # to get know available nginx* plugins
    $ sparrow plg install nginx-check  # to download and install a chosen plugin
    $ sparrow plg install nginx-check --version 0.1.1 # install specific version

To see installed plugin list say this:

    $ sparrow plg list

To get installed plugin information say this:

B<sparrow plg show $plugin_name>

To remove plugin installed use C<sparrow plg remove> command:

B<sparrow plg remove $plugin_name>

For example:

    $ sparrow plg remove df-check


=head2 Tasks API


=head3 Create tasks

To create a task use C<sparrow task add> command:

B<sparrow task add $project_name $task_name $plugin_name>

Tasks always belong to projects, so to create a task you have to create a project first if not exists.
Tasks binds a plugin with configuration, so to create a task you have to install a plugin first.

Command examples:

    $ sparrow project create system
    $ sparrow plg install df-check
    $ sparrow task add system disk-health df-check


=head3 Run plugins

There are two ways to run sparrow plugins:

=over

=item *

as_is



=item *

as tasks



=back

The first one is simplest as it does not require creating a task at all. If you don't want provide a specific plugin configuration,
you may run a plugin as is using  C<sparrow plg run> command:

B<sparrow plg run [ options ]>

For example:

    $ sparrow plg run df-check

NOTE! Only L<public plugins|#public-plugins> could be run I<as_is>.

The second way requires task creation and benefits in applying specific configuration for a plugin:

B<sparrow task run $project_name $task_name [ options ]>

For example:

    $ sparrow task run system disk-health

See L<configuring tasks|#configuring-tasks> section on how one can configure task plugin.


=head3 Setting runtime parameters 

It is possible to pass I<whatever> runtime configuration parameters when running tasks or plugins:

    $ sparrow plg run df-check --param threshold=60
    
    $ sparrow task run system disk-health --param threshold=60
    
    # or even nested and multi parameters!
    
    $ sparrow plg run foo --param foo.bar.baz=60 --param id=100

Runtime parameters override default parameters ones set in tasks configurations, see L<configuring tasks|#configuring-task> section.


=head3 Setting outthentic parameters

As sparrow runs plugins with the help of L<Outthentic scenarios runner|https://github.com/melezhik/outthentic#options> it accepts all
I<runner related> parameters, check out L<Outthentic|https://github.com/melezhik/outthentic#options> for details. Other parameters examples:

    $ sparrow task run system disk-health --silent
    $ sparrow task run system disk-health --debug 1 --prove '-Q'


=head3 Running tasks with cron

When running tasks with cron it is handy only have an output if something goes wrong, 
f.e. if plugin failed for some reasons. Use C<--cron> flag to enable this behavior:

B<sparrow task run $project_name $task_name --cron>

Running task with --cron flag suppress a normal output and only emit something in case of failures.

Example:

    $ sparrow task system disk-health --cron # pleas keep quite if disk space is ok


=head3 Configuring tasks

Task configuration is a some input parameters consumed by plugin binded to task. 
User should consult plugin documentation to get know a certain structure of configuration data to feed.

Sparrow supports two configuration formats:

=over

=item *

Config::General 


=item *

YAML


=back

Config::General format is I<default> format for task configuration.  Use C<task ini> command to set task configuration:

B<sparrow task ini $project_name $task_name>

For example:

    $ export EDITOR=nano
    
    $ sparrow task ini system disk-health
    
    # disk used threshold in %
    threshold = 80

Having this sparrow will save plugin configuration in the file related to task and will use it during task run:

    $ sparrow task run system disk-health # the value of threshold is 80

User could copy existed configuration from file using C<task load_ini> command:

B<sparrow task load_ini $project_name $task_name /path/to/ini/file>

For example:

    $ sparrow task load_ini system disk-health /etc/plugins/disk.ini

To get task configuration use C<sparrow task show> command:

B<sparrow task show $project_name $task_name>

For example:

    $ sparrow task show system disk-health

Alternative way to configure sparrow task is to load configuration from yaml file I<during> task run:

    $ cat disk.yml
    
    ---
    threshold: 80
    
    $ sparrow task run system disk --yaml disk.yml

While C<sparrow task ini/load_ini> command saves task configuration and makes it persistent,
C<sparrow task run --yaml> command applies plugin configuration only for runtime and won't save it after plugin execution.

For common usage, when user runs tasks manually first approach is more convenient, 
while the second one is a I<way automatic>, when tasks configurations are kept as yaml files
and maintained out of sparrow scope and applied during task run.


=head3 Removing tasks

Use this command to remove task from the project container:

B<sparrow task remove $project_name $task_name>

Examples:

    # remove task disk-health project system
    $ sparrow task remove system disk-health


=head1 Sparrow plugins

Sparrow plugins are shareable multipurposes scenarios installed from remote sources.

There are two type of sparrow plugins:

=over

=item *

public plugins are provided by L<SparrowHub|https://sparrowhub.org/> community repository and considered as public access.



=item *

private plugins are provided by internal or external git repositories and I<not necessary> considered as public access.



=back

Both public and private plugins are installed with help of sparrow client:

B<sparrow plg install plugin_name>


=head2 Public plugins

The public plugins features:

=over

=item *

they are kept in a central place called L<SparrowHub|https://sparrowhub.org/> - community plugins repository.



=item *

they are versioned so you may install various version of a one plugin.



=back


=head2 Private plugins

Private plugins are ones created by you and not supposed to be accessed publicly.

The private plugins features:

=over

=item *

they are kept in arbitrary remote git repositories ( public or private ones )



=item *

they are not versioned, a simple `git clone/pull' command is executed to install/update a plugin



=item *

private plugins should be listed at sparrow plugin list file (SPL file)



=back


=head3 SPL file

Sparrow plugin list is represented by text file placed at `\~/sparrow.list'

SPL file should contains lines in the following format:

I<$plugin_name $git_repo_url>

Where:

=over

=item *

git_repo_url


=back

Is a remote git repository URL

=over

=item *

plugin_name


=back

A name of your sparrow plugin, could be arbitrary name but see restriction notice concerning public plugin names.

Example entries:

    package-generic   https://github.com/melezhik/package-generic.git

Once you add a proper entries into SPL file you may list and install a private plugins:

    $ sparrow plg show package-generic


=head1 Publishing public sparrow plugin to SparrowHub

On how to create a sparrow plugins please follow L<Outthentic documentation|https://github.com/melezhik/outthentic>.

Once a plugin is create you should do 4 simple steps:

=over

=item *

get registered on SparrowHub and create a token


=item *

setup sparrowhub.json file


=item *

create a plugin meta file - sparrow.json


=item *

upload a plugin with the help of C<sparrow plg upload> command


=back


=head2 Get registered on SparrowHub

Go to L<https://sparrowhub.org/sign_up|https://sparrowhub.org/sign_up> and create an account


=head2 Generate a token

Login into SparrowHub, go to Profile page and hit "Regenerate Token" on  L<https://sparrowhub.org/token|https://sparrowhub.org/token>  page.


=head2 Setup sparrowhub.json

Once your get you token, setup a sparrowhub credentials on the machine where you are going upload plugin from:

    $ cat ~/sparrowhub.json
    
    {
        "user"  : "melezhik",
        "token" : "ADB4F4DC-9F3B-11E5-B394-D4E152C9AB83"
    }

NOTE! Another way to provide SparrowHub credentials is to set C<$sph_user> and C<$sph_token> environment variables:

    $ export sph_user=melezhik 
    $ export sph_token=ADB4F4DC-9F3B-11E5-B394-D4E152C9AB83


=head2 Create a plugin meta file sparrow.json

Sparrow.json file holds plugin  meta information required for plugin gets uploaded to SparrowHub.

Create sparrow.json file and place it in a plugin root directory:

    {
        "version": "0.1.1",
        "name": "df-check",
        "description" : "elementary file system checks using df utility report ",
        "url" : "https://github.com/melezhik/df-check"
    }

This is the list of obligatory parameters you have to set:

=over

=item *

version - perl version string.


=back

A detailed information concerning version syntax could be find here -
L<https://metacpan.org/pod/distribution/version/lib/version.pm|https://metacpan.org/pod/distribution/version/lib/version.pm>

=over

=item *

name - plugin name.


=back

Only symbols `a-zA-Z1-9_-.' are allowable in plugin name

This the list of optional parameters you may set as well:

=over

=item *

url - an http URL for the site where one could find a detailed plugin information ( docs, source code, issues ... )



=item *

description - a short description of your plugin



=back


=head2 Upload plugin

=over

=item *

Install sparrow client on your machine

$ cpanm Sparrow



=item *

Go to directory where your plugin source code at and say:

$ sparrow plg upload



=back

That's it!


=head1 Publishing private sparrow plugins

The process is almost the same as for public plugins, except you don't have to provide SparrowHub credentials
and gets registered as you host your plugin at remote git repository. 

You have to do 3 simple steps:

=over

=item *

create a plugin and commit it into local git repository, plugin root directory should be repository root directory


=item *

create plugin meta file - sparrow.json and commit it into local git repository ( sparrow.json file is the same as for public plugins )


=item *

push your changes into remote git repository


=back


=head1 Declaring dependencies

This is the way how one can declare dependencies for sparrow plugins:

    +----------+----------+
    | Language |  File    |
    +----------+----------+
    | Perl     | cpanfile |
    | Ruby     | Gemfile  |
    +----------+----------+

You should place a dependency file into a plugin root directory.


=head1 AUTHOR

L<Aleksei Melezhik|mailto:melezhik@gmail.com>


=head1 Home page

L<https://github.com/melezhik/sparrow|https://github.com/melezhik/sparrow>


=head1 Copyright

Copyright 2015 Alexey Melezhik.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.


=head1 See also

=over

=item *

L<Outthentic|https://github.com/melezhik/outthentic> - Multipurposes scenarios framework.


=back


=head1 Thanks

To God as the One Who inspires me to do my job!
