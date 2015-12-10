package Sparrow;

our $VERSION = '0.0.7';

1;

__END__

=encoding utf8


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

Sparrow project is a container for swat test suites and applications.

Sparrow project is where one run swat tests against different applications.

    sparrow project create foo

To get project info say this:

I<sparrow project show $project_name>

For example:

    sparrow project show foo

To see project list say this:

I<sparrow project list>

To remove project data say this:

I<sparrow project remove $project_name>

For example:

    sparrow project foo remove


=head2 download and install swat plugins

I<sparrow plg install $plugin_name>

Sparrow plugin is a shareable swat test suite.

One could install sparrow plugin and then run related swat tests, see L<check|#run-swat-tests> action.

    sparrow plg list # to get available plugin list
    sparrow plg install swat-nginx # to download and install a chosen plugin

Check L<sparrow-plugins|#sparrow-plugins> section to know more about sparrow plugins.

To see available plugin list say this:

I<sparrow plg list>

To see installed plugin list say this:

I<sparrow plg list --installed>

To see installed plugin info say this:

I<sparrow plg show $plugin_name>

To update installed plugin:

I<sparrow plg update $plugin_name>

This command simple execute `git pull' for cloned git repository

For example:

    sparrow plg update swat-nginx

To remove installed plugin:

I<sparrow plg remove $plugin_name>

For example:

    sparrow plg remove swat-tomcat


=head2 create checkpoints

Checkpoints tie together tested web service and sparrow plugin.

Checkpoints belong to projects, so to create a checkpoint you need to point a project.

I<sparrow project check_set $project_name $checkpoint_name>

Examples:

    sparrow project check_add foo nginx-check
    sparrow project check_add foo tomcat-app-check


=head2 setup checkpoints

Once create checkpoint need to be setup with proper sparrow plugin and  base_url

I<sparrow project check_set $project_name $checkpoint_name $args>

Examples:

    sparrow check_set foo nginx-check -p swat-nginx -u 127.0.0.1
    sparrow check_set foo tomcat-app-check -p swat-tomcat -u my.app.local:8080

Setting checkpoint means you tie together a tested web services and sparrow plugin providing a tested logic.

Base URL is a root http URL to send http requests when executing swat tests against a web service.

Base URL should be L<curl compliant|http://curl.haxx.se/docs/manpage.html>

To show checkpoint info say this:

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

To get checkpoint swat settings say this:

I<sparrow project check_show $project_name $checkpoint_name --swat>

For example:

    sparrow project check_show foo nginx-app --swat


=head2 run swat tests remotely

NOT IMPLEMENTED YET.

I<GET /$project_name/check_run/$project_name/$checkpoint_name>

Sparrow rest API allow to run swat test suites remotely over http.

    # runs sparrow rest API daemon
    sparrowd
    
    # runs swat tests via http call
    curl http://127.0.0.1:5090/check_run/foo/nginx-app


=head1 SPARROW PLUGINS

Sparrow plugins are shareable swat test suites installed from remote sources.

There are two type of sparrow plugins:

=over

=item *

public plugins - provided by community and so considered as public access



=item *

private plugins - provided by internal or external git repositories and I<not necessary> considered as public access



=back


=head2 PUBLIC PLUGINS

The public plugins features:

=over

=item *

they are versioned, so you may upgrade and downgrade them as you commonly do with any package manage tools ( cpan, apt-get, yum )



=item *

they are kept in a central place called sparrow box - remote community plugins repository



=back

To install public sparrow plugin a minimal efforts are required. You find one in a plugin listing and then install it.

Public plugins will be denoted with public type:

    sparrow  plg list  | grep public
    sparrow plg install public_plugin_name


=head2 PRIVATE PLUGINS

Private plugins are ones created by you and not supposed to be accessed publicly.

The private plugins features:

=over

=item *

they are not versioned, a simple git pull is executed to ship the plugin, this straightforward approach result in fast integration
which is in focus when doing internal development



=item *

they are kept in a arbitrary remote git repositories ( public or private ones )



=back

To install private plugin one should configure sparrow plugin list (SPL).


=head1 SPARROW PLUGINS LIST

Private sparrow plugins list is represented by text file ~/sparrow/sparrow.list

SPL file contains lines of the following format:

I<$plugin_name $git_repo_url>

Where:

=over

=item *

gitI<repo>url - is git repository URL


=item *

plugin_name - is name of sparrow plugin.


=back

For example:

    swat-yars https://github.com/melezhik/swat-yars.git
    metacpan https://github.com/CPAN-API/metacpan-monitoring.git

To install swat-yars plugin one should do following

    # add plugin to SPL
    echo swat-yars https://github.com/melezhik/swat-yars.git >> ~/sparrow/sparrow.list
    
    # install plugin
    sparrow plg install swat-yars


=head1 CREATING SPARROW PLUGINS

To accomplish this task one should be able to

=over

=item *

init local git repository and map it to remote one ( not required for public plugins )



=item *

create swat test suite



=item *

create a cpanfile to describe additional cpan dependencies ( minimal requirement is a swat module dependency )



=item *

create sparrow.json file to describe plugin meta information ( not required for private plugin )



=item *

commit changes and then push into remote ( not required for public plugins )



=back


=head2 Init git repository

Sparrow expects your swat test suite will be under git and will be accessed as remote git repository:

    git init .
    echo 'my first sparrow plugin' > README.md
    git add README.md
    git commit -m 'my first sparrow plugin' -a
    git remote add origin $your-remote-git-repository
    git push origin master


=head2 Create swat test suite

To get know what swat is and how to create swat tests please follow swat project documentation -
L<https://github.com/melezhik/swat|https://github.com/melezhik/swat>.

A simplest swat test suite to check if GET / returns 200 OK would be like this:

    echo 200 OK > get.txt


=head2 Create cpanfile

As sparrow relies on L<carton|https://metacpan.org/pod/Carton> to handle perl dependencies and execute script
the only minimal requirement is having valid cpanfile on the root directory of your swat test suite project.

For example:

    # $ cat cpanfile
    
    # yes, we need a swat to run our tests
    require 'swat';
    
    # and some other modules
    require 'HTML::Entities'


=head1 PUBLISHING SPARROW PLUGINS


=head2 Private plugin

All you need to keep a plugin source code in the remote git repository. Swat project root directory should be at repository root.

To get plugin listed at sparrow plugin list:

    echo my-plugin $your-remote-git-repository >> sparrow.list

Now you may install it:

    sparrow plg install my-plugin


=head2 Public plugin

=over

=item *

Create your plugin



=item *

Setup sparrow.json file



=back

Go to plugin directory ( should be swat project root directory ) and create sparrow.json file
to describe plugin meta information. This should be json file with 2 obligatory parameter:

    {
        "version" => "0.2.3",
        "name" => "my-cool-plugin"
    }

Version should be CPAN compatible version string. Name should be plugin name.

=over

=item *

Upload plugin


=back

Before uploading to central sparrow repository  you need to get access to SparrowBox API.

Register at http://sparrowbox-pm.org and generate API token.

Once you have one setup ~/.sparrow-box.ini file:

    echo 'user=melezhik'                                > ~/.sparrow-box.ini
    echo 'token=ADB4F4DC-9F3B-11E5-B394-D4E152C9AB83'   >> ~/.sparrow-box.ini

Now you are ready to upload a plugin with sparrow client

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
