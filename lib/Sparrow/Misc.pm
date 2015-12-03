package Sparrow::Misc;

use strict;

use base 'Exporter';
use Carp;

use File::Path;
use Sparrow::Constants;

our @EXPORT = qw {
    execute_shell_command 
    usage
    init_sparrow_env
};


sub execute_shell_command {
    my $cmd = shift;
    confess "failed execute: $cmd" unless system($cmd) == 0;
}

sub usage {

    print "usage: sparrow project|plg action args\n";
    print "where action: create|list|install|update|add_site|check_site|swat_setup. and args depend on action\n";


    print "action examples:\n";

    print "\n[projects]:\n\n";
    print "\tsparrow project foo create # create a project\n";
    print "\tsparrow project foo remove # remove a project\n";
    print "\tsparrow project foo info   # get project info\n";
    print "\tsparrow projects # list projects\n";

    print "\n[plugins]:\n\n";

    print "\tsparrow plg list           # show plugin index \n";
    print "\tsparrow plg list --local   # show installed plugins \n";
    print "\tsparrow plg install swat-nginx # install plugin \n";
    print "\tsparrow plg update swat-nginx  # update plugin\n";
    print "\tsparrow plg remove swat-nginx  # remove plugin\n";
    print "\tsparrow plg info   swat-nginx  # get plugin info\n";

    print "\n[projects and plugins]:\n\n";
    print "\tsparrow project foo add_plg swat-nginx # link plugin to project\n";


    print "\n[projects and sites]:\n\n";
    print "\tsparrow project foo add_site nginx_proxy    127.0.0.1       # create site and link it to project\n";
    print "\tsparrow project foo add_site pinto_rest_api 127.0.0.1:3111  # another site get linked to project\n";
    print "\tsparrow project foo site_info nginx_proxy                   # get site info\n";

    print "\n[swat test suites]:\n\n";
    print "\tsparrow project foo check_site nginx_proxy swat-nginx      # yet another swat test suite run \n";
    print "\tsparrow project foo check_site pinto_rest_api swat-pintod  # run swat test suite from plugin swat-tomcat, site tomcat_app\n";


    print "\tsparrow project foo swat_setup nginx_proxy # configure swat setting for site nginx_proxy\n";

    print "\n\n";

    print "follow https://github.com/melezhik/sparrow to get full documentation\n";

}




sub init_sparrow_env {

    mkpath(sparrow_root);
    mkpath(sparrow_root.'/plugins');
    mkpath(sparrow_root.'/projects');

    execute_shell_command('touch '.sparrow_root.'/sparrow.list') unless -f sparrow_root.'/sparrow.list';    
    print "# sparrow environment initialzed at ".sparrow_root, "\n";
}

1;

