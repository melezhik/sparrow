package Sparrow::Commands::Project;

use strict;

use base 'Exporter';

use Sparrow::Constants;
use Sparrow::Misc;

use Carp;
use File::Basename;
use File::Path;

use JSON;

our @EXPORT = qw{

    projects_list
    project_create
    project_show
    project_remove


    check_add
    check_show
    check_remove

    check_set
    check_swat_set


    check_run

    cp_get
    cp_set

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
        print "project $project successfully created\n\n"
    }


}

sub project_remove {

    my $project = shift or confess('usage: project_remove(project)');


    if (-d sparrow_root."/projects/$project"){
        rmtree( sparrow_root."/projects/$project" );
        print "project $project successfully removed\n\n"
    }else{
        warn "unknown project";
    }

}

sub check_remove {

    my $project = shift or confess('usage: checkpoint_remove(*project,checkpoint)');
    my $cid     = shift or confess('usage: checkpoint_remove(project,*checkpoint)');

    if (-d sparrow_root."/projects/$project" and -d sparrow_root."/projects/$project/checkpoints/$cid" ){
        rmtree( sparrow_root."/projects/$project/checkpoints/$cid" );
        print "checkpoint $project/$cid successfully removed\n\n";
    }else{
        warn "unknown checkpoint";
    }

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

    confess "unknown project" unless  -d sparrow_root."/projects/$project";

    confess "checkpoint $project/$cid already exists" if  -d sparrow_root."/projects/$project/checkpoints/$cid";

    mkdir sparrow_root."/projects/$project/checkpoints/$cid" or confess "can't create checkpoint directory: $!";

    print "checkpoint $project/$cid successfully created\n\n";

}

sub check_remove {

    my $project = shift or confess "usage: check_remove(*project,checkpoint)";
    my $cid     = shift or confess "usage: check_remove(project,*checkpoint)";

    confess "unknown project $project" unless  -d sparrow_root."/projects/$project";

    execute_shell_command("rm -rf ".sparrow_root."/projects/$project/checkpoints/$cid");

    print "checkpoint $project/$cid successfully removed \n\n";

}

sub check_set {

    my $project  = shift or confess "usage: check_set(*project,checkpoint,args)";
    my $cid      = shift or confess "usage: check_set(project,*checkpoint,args)";
    my %args     = @_;

    confess "unknown project $project" unless  -d sparrow_root."/projects/$project";
    confess "unknown project $project" unless  -d sparrow_root."/projects/$project/checkpoints/$cid";

    if ($args{'-u'}){
        cp_set($project,$cid,'base_url',$args{'-u'});
        print "set base_url\n\n";
    }    
    if ($args{'-p'}){
        cp_set($project,$cid,'plugin',$args{'-p'});
        print "set plugin\n\n";
    }    


}


sub check_swat_set {

    my $project  = shift or confess "usage: check_swat_set(*project,checkpoint)";
    my $cid      = shift or confess "usage: check_swat_set(project,*checkpoint)";

    confess "unknown project" unless  -d sparrow_root."/projects/$project";
    confess "unknown checkpoint" unless  -d sparrow_root."/projects/$project/checkpoints/$cid";

}


sub cp_get {

    my $project = shift or confess "usage: cp_get(*project,checkpoint)";
    my $cid     = shift or confess "usage: cp_get(project,*checkpoint)";

    my $data;
    
    if (open F, sparrow_root."/projects/$project/checkpoints/$cid/settings.json") { 
        my $str = join "", <F>;
        close F;
        $data = decode_json($str);
    } else {
        $data = {};
    }
    return $data;

}

sub cp_set {

    my $project  = shift or confess "usage: cp_set(*project,checkpoint,args)";
    my $cid      = shift or confess "usage: cp_set(project,*checkpoint,args)";
    my %args     = @_;

    my $cp_settings = cp_get($project,$cid); 

    open F, ">", sparrow_root."/projects/$project/checkpoints/$cid/settings.json" or 
        confess "can't open file to write: projects/$project/checkpoints/$cid/settings.json";

    for my $f (keys %args){
        $cp_settings->{$f} = $args{$f};
    }

    print F encode_json($cp_settings);
    close F;

}


sub link_is_dangling {

    my $l = shift;
    return stat($l) ? 0 : 1;
}

1;

