package Sparrow::Commands::Project;

use strict;

use base 'Exporter';

use Sparrow::Constants;
use Sparrow::Misc;

use Carp;
use File::Basename;
use File::Path;

our @EXPORT = qw{

    projects_list
    project_create
    project_show
    project_remove


    check_add
    check_run
    check_set
    check_show
    check_remove

};


sub projects_list {

    print "[sparrow projects list]\n\n";

    my $root_dir = sparrow_root.'/projects/';

    opendir(my $dh, $root_dir) || confess "can't opendir $root_dir: $!";

    for my $p (sort { -M $root_dir.$a <=> -M $root_dir.$b } grep { ! /^\.{1,2}$/ } readdir($dh)){
        print basename($p),"\n";
    }

    closedir $dh;
}

sub project_create {

    my $project = shift or confess('usage: project_create(project)');;

    if ( -d sparrow_root."/projects/$project" ){
        print "project $project already exists - nothing to do here ... \n\n"
    } else {
        mkpath sparrow_root."/projects/$project";
        mkpath sparrow_root."/projects/$project/checkpoints";
        print "project $project is successfully created\n\n"
    }


}

sub project_remove {

    my $project = shift or confess('usage: project_remove(project)');

    confess "unknown project $project" unless  -d sparrow_root."/projects/$project";

    rmtree( sparrow_root."/projects/$project" );

    print "project $project is successfully removed\n\n"


}


sub project_show {

    my $project = shift or confess('usage: project_show(project)');;

    confess "unknown project $project" unless  -d sparrow_root."/projects/$project";

    print "[project $project info]\n\n";

    print "[checkpoints]\n\n";

    my $root_dir = sparrow_root."/projects/$project/checkpoints/";

    opendir(my $dh, $root_dir) || confess "can't opendir $root_dir: $!";

    for my $p ( sort { -M $root_dir.$a <=> -M $root_dir.$b }  grep { ! /^\.{1,2}$/ } readdir($dh)){
        print "\t", basename($p),"\n";
    }

    closedir $dh;

}

sub check_add {

    my $project = shift or confess "usage: check_add(*project,checkpoint)";
    my $cid     = shift or confess "usage: check_add(project,*checkpoint)";

    confess "unknown project $project" unless  -d sparrow_root."/projects/$project";

    confess "checkpoint $cid already exists" if  -d sparrow_root."/projects/$project/checkpoints/$cid";

    mkdir sparrow_root."/projects/$project/checkpoints/$cid" or confess "can't create checkpoint directory: $!";

    print "checkpoint $cid is successfully added to project $project\n\n";

}

sub check_remove {

    my $project = shift or confess "usage: check_remove(*project,checkpoint)";
    my $cid     = shift or confess "usage: check_remove(project,*checkpoint)";

    confess "unknown project $project" unless  -d sparrow_root."/projects/$project";

    execute_shell_command("rm -rf ".sparrow_root."/projects/$project/checkpoints/$cid");

    print "checkpoint $cid is successfully removed from project $project\n\n";

}

sub add_site_to_project {

    my $project = shift or confess "usage: add_site_to_project(project,site,base_url)";
    my $sid = shift or confess "usage: add_site_to_project(project,site,base_url)";
    my $base_url = shift or confess "usage: add_site_to_project(project,site,base_url)";

    if (-d sparrow_root."/projects/$project/sites/$sid" ){
        set_site_base_url($project,$sid,$base_url);
        print "site $sid is successfully updated at project $project\n\n";
    } elsif (-d sparrow_root."/projects/$project" ){
        mkpath sparrow_root."/projects/$project/sites/$sid";
        set_site_base_url($project,$sid,$base_url);
        print "site $sid is successfully added to project $project\n\n";
    }else{
        confess "unknown project $project";

    }

}

sub site_info {

    my $project = shift or confess 'usage: site_info(*project,site)';
    my $sid     = shift or confess 'usage: site_info(project,*site)';
    my @opts    = @_;

    my $opts = join ' ', @opts;

    if (-d sparrow_root."/projects/$project/sites/$sid" ){
        my $base_url = site_base_url($project,$sid);
        print "[site info] \n";
        print "\tname: $sid\n";
        print "\tbase url: $base_url\n";
        if ($opts=~/--swat/){

            print "\n\nswat settings:\n\n";
            my $swat_ini_file =  sparrow_root."/projects/$project/sites/$sid/swat.my";
            if ( -f $swat_ini_file ){
                open F, $swat_ini_file or confess  "can't open $swat_ini_file to read: $!";
                while(my $l = <F>){
                    print $l;
                };
                close;
            } else {
                print "\n\nswat settings: not found\n";
            }
        }

    }else{
        confess "unknown site $sid in project $project";

    }
    
}

sub site_base_url {

    my $project = shift or confess "usage: site_base_url(project,site)";
    my $sid = shift or confess "usage: site_base_url(project,site)";

    open F, sparrow_root."/projects/$project/sites/$sid/base_url" or 
    confess "can't open file projects/$project/sites/$sid/base_url to read";

    my $base_url = <F>;
    chomp $base_url;
    close F;
    $base_url;

}

sub set_site_base_url {

    my $project = shift or confess "usage: set_site_base_url(project,site,base_url)";
    my $sid = shift or confess "usage: set_site_base_url(project,site,base_url)";
    my $base_url = shift or confess "usage: set_site_base_url(project,site,base_url)";

    open F, ">", sparrow_root."/projects/$project/sites/$sid/base_url" or 
        confess "can't open file to write: projects/$project/sites/$sid/base_url";
    print F $base_url;
    close F;

}


sub link_is_dangling {

    my $l = shift;
    return stat($l) ? 0 : 1;
}

1;

