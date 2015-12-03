package Sparrow::Commands::Project;

use strict;

use base 'Exporter';

use Sparrow::Constants;
use Sparrow::Misc;

use Carp;
use File::Basename;
use File::Path;

our @EXPORT = qw{

    create_project
    remove_project

    show_projects
    project_info

    add_plugin_to_project
    add_site_to_project

    site_info

    site_base_url


};


sub show_projects {

    print "[sparrow project list]\n\n";

    my $root_dir = sparrow_root.'/projects/';

    opendir(my $dh, $root_dir) || confess "can't opendir $root_dir: $!";

    for my $p (sort { -M $root_dir.$a <=> -M $root_dir.$b } grep { ! /^\.{1,2}$/ } readdir($dh)){
        print basename($p),"\n";
    }

    closedir $dh;
}

sub create_project {

    my $project = shift or confess('usage: create_project(project)');;

    if ( -d sparrow_root."/projects/$project" ){
        print "project $project already exists - nothing to do here ... \n\n"
    } else {
        mkpath sparrow_root."/projects/$project";
        mkpath sparrow_root."/projects/$project/plugins";
        mkpath sparrow_root."/projects/$project/sites";
        print "project $project is successfully created\n\n"
    }


}

sub remove_project {

    my $project = shift or confess('usage: remove_project(project)');

    confess "unknown project $project" unless  -d sparrow_root."/projects/$project";

    rmtree( sparrow_root."/projects/$project" );

    print "project $project is successfully removed\n\n"


}


sub project_info {

    my $project = shift or confess('usage: project_info(project)');;

    confess "unknown project $project" unless  -d sparrow_root."/projects/$project";

    print "[project $project info]\n\n";

    print "[plugins]\n\n";

    my $root_dir = sparrow_root."/projects/$project/plugins/";

    opendir(my $dh, $root_dir) || confess "can't opendir $root_dir: $!";

    for my $p ( sort { -M $root_dir.$a <=> -M $root_dir.$b }  grep { ! /^\.{1,2}$/ } readdir($dh)){

        if ( link_is_dangling(sparrow_root."/projects/$project/plugins/$p") ){
            unlink sparrow_root."/projects/$project/plugins/$p";
        }else{
            print "\t", basename($p),"\n";
        }
    }

    closedir $dh;


    print "\n\n\[sites]\n\n";

    my $root_dir = sparrow_root."/projects/$project/sites/";

    opendir(my $dh, $root_dir) || confess "can't opendir $root_dir: $!";

    for my $s ( sort { -M $root_dir.$a <=> -M $root_dir.$b }  grep { ! /^\.{1,2}$/ } readdir($dh)){
        my $base_url = site_base_url($project,basename($s));
        print "\t", basename($s)," [$base_url] \n";
    }

    closedir $dh;


}

sub add_plugin_to_project {

    my $project = shift or confess "usage: add_plugin_to_project(project,plugin)";
    my $pid = shift or confess "usage: add_plugin_to_project(project,plugin)";


    unless ( -d sparrow_root."/plugins/$pid" ){
        print "plugin $pid is not installed yet. run `sparrow plg install $pid` to install it\n";
        exit(1);
    }

    unless ( -d sparrow_root."/projects/$project" ){
        print "project $project does not exist. run `sparrow project $project create` to create it it\n";
        exit(1);
    }

    if ( -l sparrow_root."/projects/$project/plugins/$pid" ){

        print "projects/$project/plugins/$pid already exist - nothing to do here ... \n\n";

    }else{

        symlink File::Spec->rel2abs(sparrow_root."/plugins/$pid"), 
                File::Spec->rel2abs(sparrow_root."/projects/$project/plugins/$pid") or
        confess "can't create symlink projects/$project/plugins/$pid ==> plugins/$pid";

        print "plugin $pid is successfully added to project $project\n\n";
    }

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

