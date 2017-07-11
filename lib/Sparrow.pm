package Sparrow;

our $VERSION = '0.2.42';

1;

__END__

=pod


=encoding utf8


=head1 NAME

Sparrow


=head1 SYNOPSIS

Sparrow - multipurpose scenarios manager.


=head1 Install

    $ sudo yum install git # only required for installing private plugins
    $ sudo yum install curl
    $ cpanm Sparrow


=head1 Build status

L<![Build Status](https://travis-ci.org/melezhik/sparrow.svg)|https://travis-ci.org/melezhik/sparrow>


=head1 Sparrow plugins

Sparrow plugins are shareable multipurpose scenarios distributed via central repository - L<SparrowHub|https://sparrowhub.org>.
Every single plugin represents a various scripts to solve a specific task. Plugins are easily installed, configured and run on
dedicated servers with the help of sparrow console client. 

The notion of sparrow plugins is very close to the conception of CPAN modules in Perl or Ruby gems in Ruby.
It's just a small suites of scripts to solve a specific tasks.

Supported plugin types.

Sparrow supports two types of plugins depending on underlying runner to execute plugin scenarios. They are:

=over

=item *

L<Outthentic|https://github.com/melezhik/outthentic> Plugins



=item *

L<SWAT|https://github.com/melezhik/swat> Plugins



=back

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

Plugin configuration is just a text file in one of 4 formats:

=over

=item *

L<Config::General|https://metacpan.org/pod/Config::General> format - consumed by Outthentic plugins


=item *

YAML format - consumed by both Swat and Outthentic plugins


=item *

JSON format - consumed by Outthentic plugins


=item *

L<Config::Tiny|https://metacpan.org/pod/Config::Tiny> format - consumed by Swat plugins


=back


=head1 Projects

Projects are I<logical groups> of sparrow tasks. It is convenient to split a whole list of tasks to different logical groups. 
Like some tasks for system related issues - f.e. checking L<disk available space|https://sparrowhub.org/info/df-check> or inspecting L<stale processes|https://sparrowhub.org/info/stale-proc-check>, other tasks for
web services related issues - f.e. L<checking nginx health|https://sparrowhub.org/info/nginx-check> or L<monitoring http errors|https://sparrowhub.org/info/logdog> in web server logs, so on. 


=head1 Task Boxes

Sparrow tasks boxes are JSON format files to describe sequential tasks to run. 

You could think about sparrow boxes as of multi tasks. Sparrow runs tasks from the box sequentially.


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

    $ sparrow project remove web-servers

B<I<NOTE!>> This command will remove all project tasks as well!


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


=head3 Getting plugin man page

If plugin author supply his plugin with man page it could be shown as:

B<sparrow plg man $plugin_name>

For example:

    $ sparrow plg man df-check

Aliase. C<info> and C<help> are just aliases for C<plg man> command:

    $ sparrow plg info df-check
    $ sparrow plg help df-check


=head2 Tasks API


=head3 Create tasks

To create a task use C<sparrow task add> command:

B<sparrow task add $project_name $task_name $plugin_name [opts]>

Tasks always belong to projects, so to create a task you have to create a project first if not exists.
Tasks binds a plugin with configuration, so to create a task you have to install a plugin first.

Command examples:

    $ sparrow project create system
    $ sparrow plg install df-check
    $ sparrow task add system disk-health df-check

Options:

=over

=item *

--quiet - suppress output of this command.


=back

For example:

    $ sparrow task add system disk-health df-check --quiet 1

=over

=item *

--host - pass hostname parameter.


=back

It's useful when create tasks for swat plugins

    $ sparrow task add web nginx-check swat-nginx --host 127.0.0.1:80


=head3 Getting task list

To list all the task with projects use:

B<sparrow task list>


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

B<sparrow plg run [ parameters ]>

For example:

    $ sparrow plg run df-check

Parameters:

=over

=item *

B<verbose>


=back

Sets verbose mode to get some extra message when running plugin 

The second way requires task creation and benefits in applying specific configuration for a plugin:

B<sparrow task run $project_name $task_name [ parameters ]>

For example:

    $ sparrow task run system disk-health

See L<configuring tasks|#configuring-tasks> section on how one can configure task plugin.

Parameters:

=over

=item *

B<verbose>


=back


=head3 Setting runtime parameters 

B<I<NOTE!>> Runtime parameters are only supported for Outthentic plugins.

It is possible to pass I<whatever> runtime configuration parameters when running tasks or plugins:

    $ sparrow plg run df-check --param threshold=60
    
    $ sparrow task run system disk-health --param threshold=60
    
    # or even nested and multi parameters!
    
    $ sparrow plg run foo --param foo.bar.baz=60 --param id=100

Runtime parameters override default parameters ones set in tasks configurations, see L<configuring tasks|#configuring-task> section.


=head3 Setting plugin runner parameters

When executing sparrow plugin sparrow relies on underlying runner defined by plugin type. There are two types of sparrow plugins:

=over

=item *

Outthentic Plugins



=item *

SWAT Plugins



=back

Both runners accept specific parameters. 

For outthentic runner parameters follow L<Outthentic|https://github.com/melezhik/outthentic#options> documentation. 

For swat runner parameters follow L<Swat|https://github.com/melezhik/swat#swat-runner> documentation.

Here are some examples:

    # outthentic plugins:
    $ sparrow task run system/disk-health --format concise --purge-cache 
    $ sparrow task run system/disk-health --debug 2
    
    # swat plugins:
    $ sparrow task run web/nginx-check --prove -Q


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

Config::Tiny    ( Swat plugins )


=item *

Config::General ( Outthentic plugins )


=item *

YAML ( Outthentic and Swat plugins )


=item *

JSON ( Outthentic plugins )


=back

Use C<task ini> command to set task configuration:

B<sparrow task ini $project_name $task_name>

For example:

    $ export EDITOR=nano
    
    # Config::General format
    
    $ sparrow task ini system disk-health
    # disk used threshold in %
    threshold = 80
    
    # JSON format
    $ sparrow task ini system disk-health
    {
      "threshold": 80
    }
    
    # YAML format
    $ sparrow task ini system disk-health
    # disk used threshold in %
    threshold: 80

Having this sparrow will save plugin configuration in the file related to task and will use it during task run:

    $ sparrow task run system disk-health # the value of threshold is 80

User could copy existed configuration from file using C<task load_ini> command:

B<sparrow task load_ini $project_name $task_name /path/to/ini/file>

For example:

    $ sparrow task load_ini system disk-health /etc/plugins/disk.yaml # load from YAML file
    $ sparrow task load_ini system disk-health /etc/plugins/disk.json # load from JSON file
    $ sparrow task load_ini system disk-health /etc/plugins/disk.conf # load from Config::General file

To get task configuration use C<sparrow task show> command:

B<sparrow task show $project_name $task_name>

For example:

    $ sparrow task show system disk-health

Alternative way to configure sparrow task is to load configuration from yaml/json file I<during> task run:

    $ cat disk.yml
    
    ---
    threshold: 80
    
    $ sparrow task run system disk --yaml disk.yml
    
    $ cat disk.json
    
    {
      "threshold": 80
    }
    
    $ sparrow task run system disk --json disk.json

While C<sparrow task ini/load_ini> command saves task configuration and makes it persistent,
C<sparrow task run --yaml|--json> command applies plugin configuration only for runtime and won't save it after plugin execution.

For common usage, when user runs tasks manually first approach is more convenient, 
while the second one is a I<way automatic>, when tasks configurations are kept as yaml files
and maintained out of sparrow scope and applied during task run.


=head3 Removing tasks

Use this command to remove task from the project container:

B<sparrow task remove $project_name $task_name>

Examples:

    # remove task disk-health project system
    $ sparrow task remove system disk-health


=head3 Alternative task names notation

When working with task you may use an alternative task names notation:

    $project_name/$task_name

Examples:

    $ sparrow task run system/disk
    $ sparrow task show system/disk
    $ sparrow task remove system/disk
    $ sparrow task ini system/disk
    # so on ...


=head3 Dump task configuration

You may dump task configuration using C<--dump-config> flag, no action will be performed,
just task configuration data will be printed out in JSON format:

    $ sparrow task run system/disk --dump-config

Dump-config could be useful when copy some task configuration into other:

    $ sparrow task run system/disk --dump-config > /tmp/system-disk.json
    $ nano /tmp/system-disk.json
    $ sparrow task load ini system/disk2 /tmp/system-disk.json


=head2 Task boxes API

Use this command to run task box

B<sparrow box run $path [opts]>

Where $path sets the file path to task box json file. A structure of the file:

    [
    
      {
        "task" : "task_name",
        "plugin" : "plugin_name",
        "data" : {
            : plugin parameters 
        }
      },
      {
        // another task
      },
    
      ...
    
    ]

Command example:

    $ sparrow box run /var/sparrow/boxes/nginx.json

Thus task box files should hold a list of sparrow tasks. Here is example:

    [
    
      {
        "task" : "install favorite packages",
        "plugin" : "package_generic",
        "data" : {
          "list" : "nano curl mc hunspell"
        }
      },
      {
        "task" : "setup git",
        "plugin" : "git-base",
        "data" : {
          "email" : "melezhik@gmail.com", "name" : "Alexey Melezhik"
          
        }
      }
    
    ]

To suppress some extra message from this command use C<--mode quiet>:

    $ sparrow box run /path/to/my/box/ --mode quiet


=head1 Sparrow plugins

Sparrow plugins are shareable multipurpose scenarios installed from remote sources.

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

private plugins could be used by two methods:



=back

1) by SPL file
2) by custom sparrow repository ( aka remote SPL file )


=head3 SPL file

SPL file is located at `\~/sparrow.list' and contains lines in the following format:

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

    $ sparrow index update
    $ sparrow plg show package-generic


=head3 Custom sparrow repository

Custom sparrow repository is abstraction for I<remote SPL file>. 

To use existed custom repository add this to sparrow configuration file:

    $ cat ~/sparrow.yaml
    
    repo: 192.168.0.1:4441

This entry defines a custom repository accessible at remote host 192.168.0.1 port 4441

Once custom repository is set up you search and install custom repository plugins the same
way as with private plugins defined at SPL file.

To run your own sparrow custom reposository use L<Sparrow::Nest|https://github.com/melezhik/sparrow-nest> module.


=head1 Developing sparrow plugins

As sparrow support two types of plugins - swat and outthentic, follow a related documentation pages on
how to create I<scenarios suites> to gets packaged and distributes as a sparrow plugin:

=over

=item *

For developing outthentic scenarios suites follow L<Outthentic documentation|https://github.com/melezhik/outthentic>.



=item *

For developing swat scenarios suites follow L<Swat documentation|https://github.com/melezhik/swat>.



=back


=head1 Publishing public sparrow plugin to SparrowHub

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

B<I<NOTE!>> Another way to provide SparrowHub credentials is to set C<$sph_user> and C<$sph_token> environment variables:

    $ export sph_user=melezhik 
    $ export sph_token=ADB4F4DC-9F3B-11E5-B394-D4E152C9AB83


=head2 Create a plugin meta file sparrow.json

Sparrow.json file holds plugin  meta information required for plugin gets uploaded to SparrowHub.

Create sparrow.json file and place it in a plugin root directory:

    {
        "name": "df-check",
        "version": "0.1.1",
        "plugin_type" : "outthentic"
        "description" : "elementary file system checks using df utility report ",
        "url" : "https://github.com/melezhik/df-check",
    }

This is description of sparrow.json parameters:

=over

=item *

name - plugin name.


=back

Only symbols `a-zA-Z1-9_-.' are allowable in plugin name. This parameter is obligatory, no default value.

=over

=item *

version - Perl version string.


=back

This parameter is obligatory. A detailed information concerning version syntax could be find here - L<https://metacpan.org/pod/distribution/version/lib/version.pm|https://metacpan.org/pod/distribution/version/lib/version.pm>

=over

=item *

plugin_type - one of two - C<outthentic|swat> - sets plugin internal runner.


=back

This parameter is obligatory. Default value is C<outthentic>. 

=over

=item *

url - a plugin web site http URL


=back

This parameter is optional and could be useful when you want to refer users to plugin documentation site.

=over

=item *

description - a short description of a plugin.


=back

This one is optional, but very appreciated.


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

    +----------+-------------------+
    | Language |  File             |
    +----------+-------------------+
    | Perl     | cpanfile          |
    | Ruby     | Gemfile           |
    | Python   | requirements.txt  |
    +----------+-------------------+

You should place a dependency file into a plugin root directory.


=head1 Disable color output

To every action you may optionally add C<--nocolor> flag to disable color output:

    $ sparrow plg run df-check --nocolor


=head1 Environment variables


=head2 SPARROW_ROOT

Sets sparrow root directory. 

If set than sparrow will be looking sparrow index, SPL and configuration files at following locations:

    $SPARROW_ROOT/sparrow.index 
    $SPARROW_ROOT/sparrow.list 
    $SPARROW_ROOT/sparrow.yaml 

As well as projects, tasks and plugins data will be kept at $SPARROW_ROOT directory.

For example:

    $ export SPARROW_ROOT=/opt/sparrow


=head2 SPARROW_NO_COLOR 

Disable color output.

    $ export SPARROW_NO_COLOR=1

Also see "Disable color output" section.


=head2 SPARROWI<CONF>PATH

If set defines an alternative location for sparrow configuration file.


=head1 Remote Tasks

B<I<WARNING!>> This feature is quite experimental and should be tested.

Remote tasks are sparrow tasks SparrowHub users could I<bind> to theirs accounts:

    $ sparrow project create utils
    
    $ sparrow task add utils  git-setup git-base
    
    $ sparrow task ini utils git-setup 
    
      email melezhik@gmail.com 
      name  'Alexey Melezhik'
     
    $ sparrow task run utils git-setup

Ok, now we could "wrap" our task and upload to our account:

    $ sparrow remote task upload utils/git-setup

B<I<NOTE!>> to upload remote task you need a SparrowHub account.

Then I ssh-ing to another server to re-apply my git configuration:

    $ ssh some-other-host
    $ sparrow remote task install utils/git-setup

Now I can:

    $ sparrow task run utils git-setup

Pretty cool, huh? :)))

A shortcut for C<sparrow remote task install ... & sparrow task run> is:

    $ sparrow remote task run utils/git-setup


=head2 Share your task

I<By default> remote task uploaded to SparrowHub is only accessible by task author. This is so called
private remote task. What if you want to share some fun stuff with people? - I<Share> your task:

    $ sparrow remote task share utils/nano-rc

Now users can use your remote task:

    $ sparrow remote task install melezhik@utils/nano-rc
    $ sparrow task run utils utils nano-rc

or using shortcut in single step:

    $ sparrow remote task run melezhik@utils/nano-rc

B<I<NOTE!>> you don't need a SparrowHub account to use public remote tasks, even unregisters users can use
public remote tasks.


=head2 Hide your task

Want to hide your task again? Not a problem:

    $ sparrow remote task hide app/passwords

Now only you can use app/passwords task.


=head2 Add useful comments to task

When doing remote task upload you optionally can add a comment which will be show 
when task gets listed with C<sparrow remote task list> command:

    $ sparrow remote task upload utils/nano-rc 'makes nano.rc setup'


=head2 List remote tasks

To list your remote tasks ( both private and public ) say this:

    $ sparrow remote task list


=head2 List public tasks

To get a list of available public remote tasks say this:

    $ sparrow remote task public list


=head2 Remove remote task

And finally you can remove remote task:

    $ sparrow remote task remove app/old-stuff


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

L<SWAT|https://github.com/melezhik/swat> - Simple Web Application Test framework.



=item *

L<Outthentic|https://github.com/melezhik/outthentic> - Multipurpose scenarios framework.



=back


=head1 Thanks

To God as the One Who inspires me to do my job!
