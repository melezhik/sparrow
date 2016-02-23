package Sparrow;

our $VERSION = '0.0.20';

1;

__END__

=pod


=encoding utf8


=head1 NAME

Sparrow

L<![Build Status](https://travis-ci.org/melezhik/sparrow.svg)|https://travis-ci.org/melezhik/sparrow>


=head1 SYNOPSIS

Sparrow - outthentic tests manager.  Manages outthentic family test suites.


=head1 CAVEAT

The project is still in very alpha stage. Things might change. But you can start play with it :-)


=head1 Outthentic family frameworks

Outthentic tests are those using L<Outthentic DSL|https://github.com/melezhik/outthentic-dsl>.

Currently there are two members of outthentic family test frameworks:

=over

=item *

L<swat|https://github.com/melezhik/swat> - web application testing framework


=back

So, I<swat test suites> are those running under swat framework

=over

=item *

L<outthentic|https://github.com/melezhik/outthentic> - generic purposes testing framework


=back

So, I<generic test suites> are those running under outthentic framework

In the documentation below term `outthentic tests' relates both to swat and generic tests.


=head1 Sparrow summary

=over

=item *

console client to setup and run outthentic test suites



=item *

installs and runs sparrow plugins - shareable outthentic test suites



=item *

ability to run tests remotely over rest API (TODO)



=back


=head1 DEPENDENCIES

git, curl, bash


=head1 INSTALL

    sudo yum install git
    sudo yum install curl
    
    cpanm Sparrow


=head1 USAGE

These are actions provided by sparrow console client:


=head2 create a project

I<sparrow project create $project_name>

Create a sparrow project.

Sparrow project is a container for outthentic test suites and tested web services or applications.

Sparrow project is entry point where one run outthentic tests against different web services or applications.

Example command:

    sparrow project create dev-db-servers
    
    sparrow project create production-web-servers

To get project info say this:

I<sparrow project show $project_name>

For example:

    sparrow project show dev-db-servers

To see projects list say this:

I<sparrow project list>

To remove project data say this:

I<sparrow project remove $project_name>

For example:

    sparrow project qa-db-servers remove


=head2 search sparrow plugins

Sparrow plugin is a shareable outthentic test suite.

One could install sparrow plugin and then run related outthentic tests, see L<check|#run-tests> action for details.

To search available plugins say this:

I<sparrow plg search $pattern>

For example:

    sparrow plg search apache
    sparrow plg search nginx
    sparrow plg search ssh
    sparrow plg search mysql

Pattern should be perl regexp pattern. Examples:

=over

=item *

C<.*>     # find any   plugin


=item *

C<nginx>  # find nginx plugins


=item *

C<mysql-> # find mysql plugins


=back


=head2 build / reload sparrow index

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

You need this to get know about any updates, changes on SparrowHub public plugins repository.

See L<PUBLIC PLUGINS|#public-plugins> section for details.


=head2 download and install sparrow plugins

I<sparrow plg install $plugin_name>

For example:

    sparrow plg search  nginx        # to get know available nginx* plugins
    sparrow plg install swat-nginx   # to download and install a chosen plugin
    sparrow plg install swat-mongodb-http --version 0.3.7 # install specific version

Check L<sparrow-plugins|#sparrow-plugins> section to know more about sparrow plugins.

To see installed plugin list say this:

I<sparrow plg list>

To get installed plugin info say this:

I<sparrow plg show $plugin_name>

To remove installed plugin:

I<sparrow plg remove $plugin_name>

For example:

    sparrow plg remove df-check


=head2 create checkpoints

I<sparrow check add $project_name $checkpoint_name>

=over

=item *

Checkpoints tie together tested web service or application and sparrow plugin



=item *

Checkpoints belong to projects, so to create a checkpoint you need to point a project



=back

Command examples:

    sparrow check production-web-servers nginx
    sparrow check production-web-servers apache
    sparrow check db-servers mysql
    sparrow check my-machine sshd


=head2 setup checkpoints

I<sparrow check set $project_name $checkpoint_name $plugin_name [$host]>

Once checkpoint is created you need to setup it. 

By setting checkpoint you bind it to a certain plugin:

=over

=item *

plugin_name


=back

Is a name of plugin to run tests.

=over

=item *

host


=back

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

I<sparrow check show $project_name $checkpoint_name>

For example:

    sparrow check show production-web-servers nginx


=head2 run tests

There are two ways to run tests. 

First one is to run tests I<via checkpoint interface> :

I<sparrow check run $project_name $check_name>

Examples:

    sparrow check run my-machine sshd
    
    sparrow check run production-web-servers nginx

Second way is simply run tests I<via plugin interface> :

I<sparrow plg run $plugin_name>

The 2 tests examples above could be run as plugins tests:

    sparrow plg run sshd-check
    
    sparrow plg run swat-nginx

=over

=item *

Choose run tests via checkpoint interface when you want to add host settings for test suite.



=item *

Choose run tests via plugin interface when you have no host specific settings for test suite.



=back

I<Warning>: you can run only L<public plugins|#public-plugins> tests using plugin interface.


=head2 Running tests under cron.

I<sparrow check run $project_name $check_name --cron>

When running tests under cron mode a normal output suppressed and is emitted only if tests fails.

Example:

    sparrow check run my-machine sshd --cron


=head2 initialize checkpoints

I<sparrow check ini $project_name $checkpoint_name>

This command setups ini file for test suite provided by checkpoint's plugin.

    # ini file for foo-app test suite:
    export EDITOR=nano
    sparrow check ini foo foo-app
    
        [main]
        foo = 1
        bar = 2

More information on ini files syntax could be found here:

=over

=item *

L<swat tests ini files|https://github.com/melezhik/swat#swat-ini-files>


=item *

L<generic tests ini files|https://github.com/melezhik/outthentic#test-suite-ini-file>


=back

Alternatively you may load plugin ini file from file path

I<sparrow check load_ini $project_name $checkpoint_name path/to/file>

For example:

    sparrow check load_ini foo foo-app /path/to/ini/file


=head2 run tests remotely

NOT IMPLEMENTED YET.

I<GET /$project_name/check_run/$project_name/$checkpoint_name>

Sparrow rest API allow to run test suites remotely over http. This function is not implemented yet.

    # runs sparrow rest API daemon
    sparrowd
    
    # runs swat tests via http call
    curl http://127.0.0.1:5090/check_run/db-servers/mysql


=head2 remove checkpoints

I<sparrow check remove $project_name $checkpoint_name>

Examples:

    # remove checkpoint nginx-check in project foo
    sparrow check remove foo nginx-check


=head1 SPARROW PLUGINS

Sparrow plugins are shareable outthentic test suites installed from remote sources.

There are two type of sparrow plugins:

=over

=item *

public plugins are provided by L<SparrowHub|https://sparrowhub.org/> community plugin repository and considered as public access



=item *

private plugins are provided by internal or external git repositories and I<not necessary> considered as public access



=back

Both public and private plugins are installed with help of sparrow client:

    sparrow plg install plugin_name


=head2 PUBLIC PLUGINS

The public plugins features:

=over

=item *

they are kept in a central place called L<SparrowHub|https://sparrowhub.org/> - community plugins repository



=item *

they are versioned so you may install various version of a one plugin



=back


=head2 PRIVATE PLUGINS

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


=head3 SPL FILE

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

    sparrow plg show    swat-yars
    sparrow plg install swat-yars


=head1 CREATING SPARROW PLUGINS

Here is a brief description of the process:


=head2 swat test suite

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

Defines test framework for test suite. Default value is `swat'. Other possible value is 'generic', see
L<generic test suite section|#generic-test-suite>

=over

=item *

url - an http URL for the site where one could find a detailed plugin information ( docs, source code, issues ... )



=item *

description - a short description of your plugin



=back


=head3 generic test suite

Creation of generic tests is very similar to a swat tests, but you'd better read L<outthentic framework documentation|https://github.com/melezhik/outthentic> to 
understand the difference.

Once your test suite is ready prepare the same additional stuff as with swat test suite:

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


=head1 PUBLISHING SPARROW PLUGINS


=head2 Private plugin

All you need is to keep a plugin source code in the remote git repository.

Plugin root directory should be repository root directory.

Once a plugin is placed at git remote repository you need to add a proper entry into SPL file, see L<SPL FILE|#> section how to do this.


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

    cat ~/sparrowhub.json
    
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


=head1 COPYRIGHT

Copyright 2015 Alexey Melezhik.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.


=head1 THANKS

=over

=item *

to God as - I<For the LORD giveth wisdom: out of his mouth cometh knowledge and understanding. (Proverbs 2:6)>


=back
