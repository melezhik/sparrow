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

    $project=~/^[\w\d-\._]+$/ or confess 'project parameter does not meet naming requirements - /^[\w\d-\._]+$/';

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

    $project=~/^[\w\d-\._]+$/ or confess 'project parameter does not meet naming requirements - /^[\w\d-\._]+$/';

    if (-d sparrow_root."/projects/$project"){
        rmtree( sparrow_root."/projects/$project" );
        print "project $project successfully removed\n\n"
    }else{
        warn "unknown project $project";
    }

}

sub check_remove {

    my $project = shift or confess('usage: checkpoint_remove(*project,checkpoint)');
    my $cid     = shift or confess('usage: checkpoint_remove(project,*checkpoint)');

    $project=~/^[\w\d-\._]+$/ or confess 'project parameter does not meet naming requirements - /^[\w\d-\._]+$/';
    $cid=~/^[\w\d-\._]+$/ or confess 'checkpoint parameter does not meet naming requirements - /^[\w\d-\._]+$/';

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

    print "[project $project]\n\n";

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

    $project=~/^[\w\d-\._]+$/ or confess 'project parameter does not meet naming requirements - /^[\w\d-\._]+$/';
    $cid=~/^[\w\d-\._]+$/ or confess 'checkpoint parameter does not meet naming requirements - /^[\w\d-\._]+$/';

    mkdir sparrow_root."/projects/$project/checkpoints/$cid" or confess "can't create checkpoint directory: $!";

    print "checkpoint $project/$cid successfully created\n\n";

}


sub check_show {

    my $project  = shift or confess "usage: check_show(*project,checkpoint)";
    my $cid      = shift or confess "usage: check_show(project,*checkpoint)";

    confess "unknown project" unless  -d sparrow_root."/projects/$project";
    confess "unknown checkpoint" unless  -d sparrow_root."/projects/$project/checkpoints/$cid";


    print "[checkpoint $project/$cid]\n\n";

    local $Data::Dumper::Terse=1;
    print Dumper(cp_get($project,$cid)), "\n\n";    

    if (-f sparrow_root."/projects/$project/checkpoints/$cid/swat.my"){
       print "[swat settings]\n\n";
        open F, sparrow_root."/projects/$project/checkpoints/$cid/swat.my" 
            or confess "can't open ".sparrow_root."/projects/$project/checkpoints/$cid/swat.my to read: $!";
        print join "", <F>;
        close F;
    }else{
       print "swat settings: not found\n"
    }


}


sub check_set {

    my $project  = shift or confess "usage: check_set(*project,checkpoint,args)";
    my $cid      = shift or confess "usage: check_set(project,*checkpoint,args)";
    my %args     = @_;

    confess "usage: check_set(project,checkpoint,*args)" unless %args;

    confess "unknown project" unless  -d sparrow_root."/projects/$project";
    confess "unknown checkpoint" unless  -d sparrow_root."/projects/$project/checkpoints/$cid";


    for my $f (keys %args){
        confess "unknow arg: $f" unless $f=~/^-(u|p)$/;
    }


    if ($args{'-u'}){
        cp_set($project,$cid,'base_url',$args{'-u'});
        print "set base_url\n\n";
    }    

    if ($args{'-p'}){

        my $pid = $args{'-p'};

        my $ptype;
    
        if ($pid=~/(public|private)@/){
            $ptype = $1;
            $pid=~s/(public|private)@//;
        }
        
        if (! $ptype and -f sparrow_root."/plugins/public/$pid/sparrow.json" and -d sparrow_root."/plugins/private/$pid" ){
        warn "both public and private $pid plugin exists;
choose `public\@$pid` or `private\@$pid`
to overcome this ambiguity";
            return;
        }elsif( -f sparrow_root."/plugins/public/$pid/sparrow.json"  and $ptype ne 'private' ){
            cp_set($project,$cid,'plugin',"public\@$pid");
            print "set plugin to public\@$pid\n\n";
        }elsif( -d sparrow_root."/plugins/private/$pid/" and $ptype ne 'public'  ){
            cp_set($project,$cid,'plugin',"private\@$pid");
            print "set plugin to private\@$pid\n\n";
        }else{
            confess "plugin is not installed, you need to install it first to use in checkpoint";
        }    
    }

}


sub check_swat_set {

    my $project  = shift or confess "usage: check_swat_set(*project,checkpoint)";
    my $cid      = shift or confess "usage: check_swat_set(project,*checkpoint)";

    confess "unknown project" unless  -d sparrow_root."/projects/$project";
    confess "unknown checkpoint" unless  -d sparrow_root."/projects/$project/checkpoints/$cid";
    confess "please setup your preferable editor via EDITOR environment variable\n" unless editor;

    exec editor.' '.sparrow_root."/projects/$project/checkpoints/$cid/swat.my";

}


sub check_run {

    my $project  = shift or confess "usage: check_run(*project,checkpoint)";
    my $cid      = shift or confess "usage: check_run(project,*checkpoint)";


    confess "unknown project" unless  -d sparrow_root."/projects/$project";
    confess "unknown checkpoint" unless  -d sparrow_root."/projects/$project/checkpoints/$cid";

    my $cp_set = cp_get($project,$cid);

    confess "plugin not set" unless $cp_set->{'plugin'};
    confess "base_url not set" unless $cp_set->{'base_url'};

    
    my $pdir = sparrow_root."/plugins/".($cp_set->{'install_dir'});

    confess 'plugin not installed' unless -d $pdir;

    my $cmd = 'cd '.sparrow_root."/projects/$project/checkpoints/$cid && swat $pdir ".($cp_set->{base_url});
    
    print "# running $cmd ...\n\n";
    exec $cmd;


}


sub cp_get {

    my $project = shift or confess "usage: cp_get(*project,checkpoint)";
    my $cid     = shift or confess "usage: cp_get(project,*checkpoint)";

    my $data;
    
    if (open F, sparrow_root."/projects/$project/checkpoints/$cid/settings.json") { 
        my $str = join "", <F>;
        close F;
        $data = decode_json($str);
        if ($data->{plugin}) {
            my ($t,$name) = split '@' , $data->{plugin};
            $data->{install_dir} =  "$t/$name";
            $data->{type} = $t;
        }
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


1;

