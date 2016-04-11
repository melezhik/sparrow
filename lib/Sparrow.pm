package Sparrow;

our $VERSION = '0.0.22';

1;

__END__

=pod


=encoding utf8


=head1 NAME

Sparrow

L<![Build Status](https://travis-ci.org/melezhik/sparrow.svg)|https://travis-ci.org/melezhik/sparrow>


=head1 SYNOPSIS

Sparrow - outthentic plugins manager.  Manages outthentic family suites.


=head1 CAVEAT

The project is still in very alpha stage. Things might change. But you can start play with it :-)


=head1 Install

    $ sudo yum install git
    $ sudo yum install curl # skip this if you are not going to use private sparrow plugins
    $ cpanm Sparrow


=head1 Glossary 


=head2 Outthentic suites

Outthentic suites are small testing / monitoring suites for various cases from monitoring available disk space
to checking if your web server is healthy. Term outthentic refers to L<Outthentic DSL|https://github.com/melezhik/outthentic-dsl>
which is DSL used in such a suites. There are 2 type of outthentic suites - swat and generic. Read further.


=head2 Sparrow plugins

Sparrow plugins are shareable outthentic suites distributed via outthentic suites repository - L<SparrowHub|https://sparrowhub.org>.
Term plugins refers to the idea of different outthentic suites could be pluggable and so get used on single machine
via a unified interface of sparrow console client. It is very close to the conception of CPAN modules in Perl or ruby gems in Ruby.


=head2 SparrowHub

SparrowHub is a L<Central repository|https://sparrowhub.org> of sparrow plugins. 


=head2 Sparrow tool

C<sparrow> is a console client to search, install, setup and finally run various sparrow plugins.
Think about it as of cpan client for CPAN modules or gem client for ruby gems.


=head2 Two types of sparrow plugins

There are tow types of outthentic suites or sparrow plugins:

=over

=item *

Swat test suites



=item *

Generic test suites



=back


=head2 Swat test suites

Are those based on L<swat|https://github.com/melezhik/swat> web application testing framework.
Swat is in turn based on Outthentic DSL.


=head2 Generic suites

Are those base on L<outthentic|https://github.com/melezhik/outthentic> generic purposes testing / monitoring framework.
Outthentic framework is in turn based in Outthentic DSL.


=head1 Sparrow basic entities

Basically user deal with 3 type of entities:


=head2 Plugins

A sparrow plugins which you search, install and (optionally) configure. Usually plugin is a small
monitoring / testing suite to solve a specific issue. For example check available disk space of
ensure service is running. There are a plenty of plugins at SparrowHub.


=head2 Checkpoints 

Checkpoint is configurable sparrow plugin. Some plugins does not require configuration and could be run as is,
but many ones require some piece of input data. For example hostname o be verified or internal parameters to
to adjust plugin logic. Checkpoint is a container for:

=over

=item *

plugin


=item *

plugin configuration


=back

Plugin configuration is just a text file in one of 2 formats:

=over

=item *

.ini style format


=item *

YAML format


=back

Plugin configuration will be explain latter.


=head2 Projects

Projects are logic groups of sparrow checkpoints. It's convenient to split a whole list of checkpoint to
different logical groups. Like one for system checks - disk available space or RAM status, other
for web servers status so on. 


=head1 API

Now having a knowledges about basic sparrow entities let's dive  into sparrow API provided by C<sparrow>
console client.


=head2 Projects API

Sparrow project is a logical group of sparrow checkpoints. To create a project use this command:

I<sparrow project create $project_name>

Example command:

    # system level checks
    $ sparrow project create system
    
    # web servers checks
    $ sparrow project create web-servers

To get project info say this:

I<sparrow project show $project_name>

For example:

    $ sparrow project show system

To get all projects list say this:

I<sparrow project list>

To remove project data say this:

I<sparrow project remove $project_name>

For example:

    $ sparrow project web-servers remove

Note - this command will remove all checkpoints related to project as well!


=head2 Search plugins API

Sparrow plugin is a shareable outthentic suite.

One could install sparrow plugin and then run related outthentic scenarios, see L<check|#run-tests> action for details.

To search available plugins say this:

I<sparrow plg search $pattern>

For example:

    # list all available plugins
    $ sparrow plg search 
      
    # find foo-* plugins
    $ sparrow plg search foo

Pattern should be perl regexp pattern. Examples:

=over

=item *

C<.*>     # find any   plugin


=item *

C<nginx>  # find nginx plugins


=item *

C<mysql-> # find mysql plugins


=back


=head2 Sparrow index API

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

I<sparrow index summary>


=back

This command will show timestamps and file locations for public and private index files

I<sparrow index update>

This command will fetch fresh index from SparrowHub and update local cached index.

This is very similar to what C<cpan index reload> command does.

You need this to get know about any updates, changes of SparrowHub repository.

See L<PUBLIC PLUGINS|#public-plugins> section for details on sparrow public plugins and SparrowHub.


=head2 Installing sparrow plugins

I<sparrow plg install $plugin_name>

For example:

    $ sparrow plg search  nginx        # to get know available nginx* plugins
    $ sparrow plg install nginx-check  # to download and install a chosen plugin
    $ sparrow plg install swat-mongodb-http --version 0.3.7 # install specific version

Check L<sparrow-plugins|#sparrow-plugins> section to know more about sparrow plugins.

To see installed plugin list say this:

I<sparrow plg list>

To get installed plugin info say this:

I<sparrow plg show $plugin_name>

To remove installed plugin:

I<sparrow plg remove $plugin_name>

For example:

    $ sparrow plg remove df-check


=head2 Checkpoints API

To create a checkpoint use this command:

I<sparrow check add $project_name $checkpoint_name>

Checkpoints are parts of projects, so to create a checkpoint you always have to point a project.

Command examples:

    $ sparrow check add web-servers nginx
    $ sparrow check add system disk


=head2 Setup checkpoints

Setting checkpoint you:

=over

=item *

bind checkpoint to sparrow plugin


=item *

(optionally) set hostname parameter for sparrow plugin


=back

This command is used to set checkpoint:

I<sparrow check set $project_name $checkpoint_name $plugin_name [$host]>

=over

=item *

hostname


=back

This optional parameter sets base url or hostname of a web service or application being tested.

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

To get checkpoint detailed information say this:

I<sparrow check show $project_name $checkpoint_name>

For example:

    $ sparrow check show webservers nginx


=head2 Run suites

There are two ways to run outthentic suites:

First one is to run suite I<via checkpoint interface> :

I<sparrow check run $project_name $check_name>

Examples:

    $ sparrow check run system disk

Second way is simply run tests I<via plugin interface> , in this case you do not need a checkpoint at all
to run a plugin, but the other side of this - you rely on I<default> plugin configuration and can't
define your own one:

I<sparrow plg run $plugin_name>

  $ sparrow plg run system disk

=over

=item *

Choose checkpoint interface when you want to add some specific settings for outthentic suite.



=item *

Choose plugin interface when you have no host specific settings for suite and default settings are just enough for you.
Notice that many sparrow plugins still require a specific configuration and can't be run  this way.



=item *

Only L<public plugins|#public-plugins> could be run using plugin interface.



=back


=head2 Running tests under cron

I<sparrow check run $project_name $check_name --cron>

When running suite with cron mode enabled a normal output suppressed and is only emitted if suite fails.

Example:

    $ sparrow check system disk --cron


=head2 Configuring checkpoints

Checkpoint configuration is configuration for plugin binded to checkpoint. Use this command to
set checkpoint configuration:

I<sparrow check ini $project_name $checkpoint_name>

This command configures sparrow plugin binded to checkpoint. There are two formats supported:

=over

=item *

YAML


=item *

.ini 


=back

Sparrow will examine a content of configuration file and try to identify format automatically.

For example for .ini format:

    $ export EDITOR=nano
    
    $ sparrow check ini system disk
    
        [disk]
        # disk used threshold in %
        threshold = 80

Or yaml format:

    $ sparrow check ini system disk
    
    ---
    disk
      threshold: 80

More information on outthentic suites configuration could be found here:

=over

=item *

L<swat suites configuration files|https://github.com/melezhik/swat#swat-ini-files>


=item *

L<generic suites configuration files|https://github.com/melezhik/outthentic#test-suite-ini-file>


=back

Alternatively you may load plugin ini file from file path

I<sparrow check load_ini $project_name $checkpoint_name path/to/file>

For example:

    $ sparrow check load_ini foo foo-app /etc/plugins/foo-app.ini
    $ sparrow check load_ini foo foo-app /etc/plugins/foo-app.yml


=head2 Removing checkpoints

Use this command to remove checkpoint data from project container:

I<sparrow check remove $project_name $checkpoint_name>

Examples:

    # remove checkpoint nginx from project web-servers
    $ sparrow check remove web-servers nginx


=head1 Sparrow plugins

Sparrow plugins are shareable outthentic suites installed from remote sources.

There are two type of sparrow plugins:

=over

=item *

public plugins are provided by L<SparrowHub|https://sparrowhub.org/> community plugin repository and considered as public access.



=item *

private plugins are provided by internal or external git repositories and I<not necessary> considered as public access.



=back

Both public and private plugins are installed with help of sparrow client:

I<sparrow plg install plugin_name>


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

    swat-yars   https://github.com/melezhik/swat-yars.git
    metacpan    https://github.com/CPAN-API/metacpan-monitoring.git

Once you add a proper entries into SPL file you may list and install a private plugins:

    $ sparrow plg show    swat-yars
    $ sparrow plg install swat-yars


=head1 Create sparrow plugin

Here is a brief description of the process:


=head2 Swat test suites

To get know to create swat tests please follow swat project documentation -
L<https://github.com/melezhik/swat|https://github.com/melezhik/swat>.

A simplest swat test to check that web service returns `200 OK' when receive `GET /' request will be:

    echo 200 OK > get.txt


=head3 create a cpanfile

As sparrow relies on L<carton|https://metacpan.org/pod/Carton> to handle perl dependencies you need to create a valid
L<cpanfile|https://metacpan.org/pod/cpanfile> in the plugin root directory.

The minimal dependency you have to declare is swat perl module:

    $ cat cpanfile
    
    require 'swat';

Of course you may also add other dependencies your plugin might need:

    $ cat cpanfile
    
    require 'HTML::Entities'


=head3 create sparrow.json file

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

engine 


=back

Defines framework for suite. Default value is `swat'. Other possible value is 'generic', see
L<generic suites section|#generic-suites>

=over

=item *

url - an http URL for the site where one could find a detailed plugin information ( docs, source code, issues ... )



=item *

description - a short description of your plugin



=back


=head3 Generic suites

Creation of generic suites is very similar to a swat test suites, but you'd better read L<outthentic framework documentation|https://github.com/melezhik/outthentic> to 
understand the difference.

Once your suite is ready add the same metadata as with swat test suite:

=over

=item *

cpanfile


=item *

sparrow.json


=back

Cpanfile should declare at least a dependency on Outthentic perl module:

    $ cat cpanfile
    
    require 'Outthentic';

Sparrow.json file does not differ from the one described at L<swat test suite|#swat-test-suite> section, except for
`engine' field value:

    {
        "engine": "generic"
    }


=head1 Publishing sparrow plugins


=head2 Private plugin

=over

=item *

All you need is to keep a plugin source code in the remote git repository.



=item *

Plugin root directory should be repository root directory.



=item *

Once a plugin is placed at git remote repository you need to add a proper entry into SPL file, see L<SPL FILE|#> section how to do this.



=back


=head2 Public plugin

To publish you plugin into SparrowHub you need:

=over

=item *

Get registered at SparrowHub


=back

Go to L<https://sparrowhub.org|https://sparrowhub.org>

=over

=item *

Get rest api token


=back

Login into your account. Go on "Profile" page, then on "My Token" page and then hit "Regenerate Token" link.

Once your get you token, setup a sparrowhub credentials on the machine where your are going upload plugin from:

    $ cat ~/sparrowhub.json
    
    {
        "user"  : "melezhik",
        "token" : "ADB4F4DC-9F3B-11E5-B394-D4E152C9AB83"
    }

=over

=item *

Upload plugin

=over

=item *

Check if you have sparrowhub credentials setup correctly ( previous step ) on your machine


=item *

Install sparrow client on your machine


=item *

Then go to directory where your plugin source code at and say `sparrow plg upload'. That's it


=back



=back

For example:

    $ cd plugin_root_directory
    $ sparrow plg upload

Another way to supply sparrow with valid SparrowHub credentials - use C<sph_user> and C<sph_token> environment variables.
Probably useful in automation scripts:

    $ sph_user=melezhik sph_token=ADB4F4DC-9F3B-11E5-B394-D4E152C9AB83 sparrow plg upload


=head1 AUTHOR

L<Aleksei Melezhik|mailto:melezhik@gmail.com>


=head1 Home page

https://github.com/melezhik/sparrow


=head1 Copyright

Copyright 2015 Alexey Melezhik.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.


=head1 Thanks

=over

=item *

to God as - I<For the LORD giveth wisdom: out of his mouth cometh knowledge and understanding. (Proverbs 2:6)>


=back
