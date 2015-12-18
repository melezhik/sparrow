package Sparrow;

our $VERSION = '0.0.7';

1;

__END__

=pod


=encoding utf8


=head1 NAME

Sparrow


=head1 SYNOPSIS

Sparrow - L<swat|https://github.com/melezhik/swat> based monitoring tool.


=head1 CAVEAT

The project is still in very alpha stage. Things might change. But you can start play with it :-)


=head1 FEATURES

=over

=item *

console client to setup and run swat test suites


=item *

installs and runs sparrow plugins - shareable swat test suites


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

Sparrow project is a container for swat test suites and tested web services.

Sparrow project is entry point where one run swat tests against different applications.

Example command:

    sparrow project create foo

To get project info say this:

I<sparrow project show $project_name>

For example:

    sparrow project show foo

To see projects list say this:

I<sparrow project list>

To remove project data say this:

I<sparrow project remove $project_name>

For example:

    sparrow project foo remove


=head2 search sparrow plugins

Sparrow plugin is a shareable swat test suite.

One could install sparrow plugin and then run related swat tests, see L<check|#run-swat-tests> action for details.

To search available plugins say this:

I<sparrow plg search $pattern>

For example:

    sparrow plg search nginx

Pattern should be perl regexp pattern. Examples:

=over

=item *

.*    # find any


=item *

nginx # find nginx plugins


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

    sparrow plg search nginx # to get know available nginx* plugins
    sparrow plg install swat-nginx # to download and install a chosen plugin
    sparrow plg install swat-mongodb-http --version 0.3.7 # install specific version

Check L<sparrow-plugins|#sparrow-plugins> section to know more about sparrow plugins.

To see installed plugin list say this:

I<sparrow plg list>

To get installed plugin info say this:

I<sparrow plg show $plugin_name>

To remove installed plugin:

I<sparrow plg remove $plugin_name>

For example:

    sparrow plg remove swat-tomcat


=head2 create checkpoints

I<sparrow project check_add $project_name $checkpoint_name>

=over

=item *

Checkpoints tie together tested web service and sparrow plugin



=item *

Checkpoints belong to projects, so to create a checkpoint you need to point a project



=back

Command examples:

    sparrow project check_add foo nginx-check
    sparrow project check_add foo tomcat-app-check


=head2 setup checkpoints

I<sparrow project check_set $project_name $checkpoint_name $args>

Once checkpoint is created you need to setup it. Setting checkpoint means providing 2 obligatory parameters:

=over

=item *

-p plugin_name


=item *

-u base_url


=back

A plugin name sets a sparrow plugin to run swat test suite from.

A base url sets a web service root URL to send http requests provided by test suite.

Base url be set in L<curl compliant|http://curl.haxx.se/docs/manpage.html>.

Command examples:

    sparrow check_set foo nginx-check -p swat-apache -u 127.0.0.1
    sparrow check_set foo nginx-check -p swat-nginx -u http://127.0.0.1
    sparrow check_set foo tomcat-app-check -p swat-tomcat -u my.app.local:8080/foo/bar

To get checkpoint info say this:

I<sparrow project check_show $project_name $checkpoint_name>

For example:

    sparrow project check_show foo nginx-check


=head2 run swat tests

I<sparrow project check_run $project_name $checkpoint_name>

Once sparrow project is configured and has some checkpoints you may run swat tests:

Examples:

    sparrow project check_run foo nginx-check
    
    sparrow project check_run foo tomcat-app-check


=head2 customize swat settings for checkpoint

I<sparrow project check_set $project_name $checkpoint_name --swat>

Executing check_set action with `--swat' flag allow to customize swat settings for given checkpoint.

This command setups L<swat ini file|https://github.com/melezhik/swat#swat-ini-files> for swat test suite provided by plugin.

    export EDITOR=nano
    sparrow project check_set foo nginx-app --swat
    
        port=88
        prove_options='-sq'

More information on swat ini files syntax could be found here - L<https://github.com/melezhik/swat#swat-ini-files|https://github.com/melezhik/swat#swat-ini-files>

To see checkpoint swat settings say this:

I<sparrow project check_show $project_name $checkpoint_name --swat>

For example:

    sparrow project check_show foo nginx-app --swat


=head2 run swat tests remotely

NOT IMPLEMENTED YET.

I<GET /$project_name/check_run/$project_name/$checkpoint_name>

Sparrow rest API allow to run swat test suites remotely over http. This function is not implemented yet.

    # runs sparrow rest API daemon
    sparrowd
    
    # runs swat tests via http call
    curl http://127.0.0.1:5090/check_run/foo/nginx-app


=head1 SPARROW PLUGINS

Sparrow plugins are shareable swat test suites installed from remote sources.

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

    sparrow plg info    swat-yars
    sparrow plg install swat-yars


=head1 CREATING SPARROW PLUGINS

Here is a brief description of the process:


=head2 create swat test suite

To get know to create swat tests please follow swat project documentation -
L<https://github.com/melezhik/swat|https://github.com/melezhik/swat>.

A simplest swat test to check that web service returns `200 OK' when receive `GET /' request will be:

    echo 200 OK > get.txt


=head2 create a cpanfile

As sparrow relies on L<carton|https://metacpan.org/pod/Carton> to handle perl dependencies you need to create a valid
L<cpafile|https://metacpan.org/pod/cpanfile> in the plugin root directory.

The minimal dependency you have to declare is swat perl module:

    $ cat cpanfile
    
    require 'swat';

Of course you may also add other dependencies your plugin might need:

    $ cat cpanfile
    
    require 'HTML::Entities'


=head2 create sparrow.json file

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

Go to L<http://sparrowhub.org|http://sparrowhub.org>

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
