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
    my %opts = @_;

    my $st = ( system($cmd) == 0 );

    if ($opts{silent}){
        die "failed to execute shell command" unless $st;
    } else {
        confess "failed to execute shell command: $cmd" unless $st;
    }
}

sub usage {

    print "usage: sparrow project|plg|index action args\n";
    print "where action: list|search|create|remove|show|install|check_add|check_run|check_set|check_remove and args depend on action\n";


    print "action examples:\n";

    print "\n[index]:\n\n";
    print "\tsparrow index update  # get freash index from SparrowHub\n";
    print "\tsparrow index summary # print cached index summary\n";

    print "\n[projects]:\n\n";
    print "\tsparrow project create foo # create a project\n";
    print "\tsparrow project remove foo # remove a project\n";
    print "\tsparrow project show foo   # get project info\n";
    print "\tsparrow project list       # list projects\n";

    print "\n[plugins]:\n\n";

    print "\tsparrow plg search foo          # search plugins \n";
    print "\tsparrow plg list                # show installed plugins \n";
    print "\tsparrow plg install df-check    # install plugin \n";
    print "\tsparrow plg remove  df-check    # remove plugin\n";
    print "\tsparrow plg show    df-check    # get plugin info\n";
    print "\tsparrow plg run     df-check    # run plguin tests\n";


    print "\n[checkpoints]:\n\n";
    print "\tsparrow check add      system disk           # create checkpoint named `disk' in project system\n";
    print "\tsparrow check set      system disk df-disk   # bind check point to plugin \n";
    print "\tsparrow check remove   system disk       # remove checkpoint named `disk' in project foo\n";
    print "\tsparrow check show     system disk       # get checkpoint info \n";
    print "\tsparrow check run      system disk       # run checkpoint tests \n";
    print "\tsparrow check ini      system disk       # populate plugin configuration \n";
    print "\tsparrow check load_ini system disk /path/to/ini/file # load plugin configuration from ini file \n";
    print "\tsparrow check load_yml system disk /path/to/yml/file # load plugin configuration from yml file \n";

    print "\n\n";

    print "follow https://github.com/melezhik/sparrow to get full documentation\n";

}




sub init_sparrow_env {

    mkpath(sparrow_root);
    mkpath(sparrow_root.'/plugins/private');
    mkpath(sparrow_root.'/plugins/public');
    mkpath(sparrow_root.'/projects');
    mkpath(sparrow_root.'/reports');

    execute_shell_command('touch '.spl_file()) unless -f spl_file();
}

1;

