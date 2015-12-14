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
    print "where action: list|create|remove|show|install|check_add|check_run|check_set|check_remove and args depend on action\n";


    print "action examples:\n";

    print "\n[projects]:\n\n";
    print "\tsparrow project create foo # create a project\n";
    print "\tsparrow project remove foo # remove a project\n";
    print "\tsparrow project show foo   # get project info\n";
    print "\tsparrow project list       # list projects\n";

    print "\n[plugins]:\n\n";

    print "\tsparrow plg list                # show available plugin list \n";
    print "\tsparrow plg list --installed    # show installed plugins \n";
    print "\tsparrow plg install swat-nginx  # install plugin \n";
    print "\tsparrow plg remove  swat-nginx  # remove plugin\n";
    print "\tsparrow plg show    swat-nginx  # get plugin info\n";


    print "\n[checkpoints]:\n\n";
    print "\tsparrow project check_add    foo nginx         # create checkpoint named `nginx' in project foo\n";
    print "\tsparrow project check_remove foo nginx         # remove checkpoint named `nginx' in project foo\n";
    print "\tsparrow project check_show   foo nginx         # get checkpoint info \n";
    print "\tsparrow project check_show   foo nginx --swat  # get checkpoint info, with swat settings \n";
    print "\tsparrow project check_run    foo nginx         # run checkpoint tests info \n";
    print "\tsparrow project check_set    foo nginx -u 127.0.0.1 -p swat-nginx  # set checkpoint parameters \n";

    print "\n\n";

    print "follow https://github.com/melezhik/sparrow to get full documentation\n";

}




sub init_sparrow_env {

    mkpath(sparrow_root);
    mkpath(sparrow_root.'/plugins/private');
    mkpath(sparrow_root.'/plugins/public');
    mkpath(sparrow_root.'/projects');

    print "# sparrow environment initialized at ".sparrow_root, "\n";
}

1;

