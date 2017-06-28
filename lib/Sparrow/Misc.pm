package Sparrow::Misc;

use strict;

use base 'Exporter';
use Carp;
use YAML qw{LoadFile};

use File::Path qw(make_path remove_tree);

use Sparrow::Constants;

our @EXPORT = qw {
    execute_shell_command 
    usage
    init_sparrow_env
    sparrow_config
};

my $sparrow_config;

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

    print "usage: sparrow index|plg|project|task action args\n\n";

    print "action examples:\n\n";

    print "\[index]:\n\n";
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
    print "\tsparrow plg man     df-check    # get plugin manual\n";
    print "\tsparrow plg run     df-check    # run plguin tests\n";


    print "\n[tasks]:\n\n";
    print "\tsparrow task add         system disk df-check    # create task named `disk' tied to plugin df-check in project system\n";
    print "\tsparrow task remove      system disk             # remove task named `disk' in project foo\n";
    print "\tsparrow task show        system disk             # get `disk' task info \n";
    print "\tsparrow task run         system disk             # run `disk' task \n";
    print "\tsparrow task ini         system disk             # populate task plugin configuration \n";
    print "\tsparrow task load_ini    system disk /path/to/ini/file # load plugin configuration from file \n";
    print "\tsparrow task list                                # get tasks and projects list \n";

    print "\n[task boxes]:\n\n";
    print "\tsparrow box run /path/to/box.json # run task box \n";

    print "\n[remote tasks]:\n\n";
    print "\tsparrow remote task upload  utils/git-setup        # upload task named `git-setup' to your SparrowHub account\n";
    print "\tsparrow remote task install utils/git-setup        # install your remote task utils/git-setup\n";
    print "\tsparrow remote task install john\@utils/git-setup   # install John's remote task utils/git-setup\n";
    print "\tsparrow remote task share utils/git-setup          # share task named `git-setup' \n";
    print "\tsparrow remote task hide utils/git-setup           # hide task named `git-setup' \n";
    print "\tsparrow remote task list                           # list your remote tasks\n";
    print "\tsparrow remote task public list                    # list public remote tasks\n";
    print "\tsparrow remote task remove utils/git-setup         # remove remote task named `git-setup' \n";

    print "\n\n";

    print "follow https://github.com/melezhik/sparrow to get full documentation\n";

}




sub init_sparrow_env {

    make_path(sparrow_root);
    make_path(sparrow_root.'/plugins/private');
    make_path(sparrow_root.'/plugins/public');
    make_path(sparrow_root.'/projects');
    #remove_tree(sparrow_root.'/cache');

    make_path(sparrow_root.'/cache');

    execute_shell_command('touch '.spi_file()) unless -f spi_file();

    execute_shell_command('touch '.spl_file()) unless -f spl_file();

    execute_shell_command('touch '.spci_file()) unless -f spci_file();

    if (-f sparrow_conf_file()){
      ($sparrow_config) = LoadFile(sparrow_conf_file());
    }
}

sub sparrow_config {
    $sparrow_config||{};
}

1;

