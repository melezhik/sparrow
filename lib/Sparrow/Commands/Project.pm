package Sparrow::Commands::Project;

use strict;

use base 'Exporter';

use Sparrow::Constants;
use Sparrow::Misc;

use Carp;
use File::Basename;
use File::Path;

use JSON;
use Data::Dumper;

our @EXPORT = qw{

    projects_list
    project_create
    project_show
    project_remove

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

    $project=~/^[\w\d-\._]+$/ or confess 'project parameter does not meet naming requirements - /^[\w\d-\._]+$/';

    if ( -d sparrow_root."/projects/$project" ){
        print "project $project already exists - nothing to do here ... \n\n"
    } else {
        mkpath sparrow_root."/projects/$project";
        mkpath sparrow_root."/projects/$project/tasks";
        print "project $project successfully created\n\n"
    }


}

sub project_show {

    my $project = shift or confess('usage: project_show(project)');;

    confess "unknown project $project" unless  -d sparrow_root."/projects/$project";

    print "[project $project]\n\n";

    print "[tasks]\n\n";

    my $root_dir = sparrow_root."/projects/$project/tasks/";

    opendir(my $dh, $root_dir) || confess "can't opendir $root_dir: $!";

    for my $p ( sort { -M $root_dir.$a <=> -M $root_dir.$b }  grep { ! /^\.{1,2}$/ } readdir($dh)){
        print "\t", basename($p),"\n";
    }

    closedir $dh;

}


sub project_remove {

    my $project = shift or confess('usage: project_remove(project)');

    $project=~/^[\w\d-\._]+$/ or confess 'project parameter does not meet naming requirements - /^[\w\d-\._]+$/';

    if (-d sparrow_root."/projects/$project"){
        rmtree( sparrow_root."/projects/$project" );
        print "project $project successfully removed\n\n"
    }else{
        warn "unknown project $project";
    }

}

1;

