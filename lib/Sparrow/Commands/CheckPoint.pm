package Sparrow::Commands::CheckPoint;

use strict;

use base 'Exporter';

use Sparrow::Constants;
use Sparrow::Misc;
use Sparrow::Commands::Plugin;

use Carp;
use File::Basename;
use File::Path;

use JSON;
use Data::Dumper;
use File::Copy;

our @EXPORT = qw{

    check_add
    check_show
    check_remove

    check_set
    check_ini
    check_load_ini

    check_run

    cp_get
    cp_set

};

sub check_add {

    my $project = shift or confess "usage: check_add(*project,checkpoint)";
    my $cid     = shift or confess "usage: check_add(project,*checkpoint)";

    confess "unknown project" unless  -d sparrow_root."/projects/$project";

    if  (-d sparrow_root."/projects/$project/checkpoints/$cid"){
      print "checkpoint $project/$cid already exists - nothing to do here\n\n";
      exit(0);
    }

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

    my $ini_file = sparrow_root."/projects/$project/checkpoints/$cid/suite.ini";

    if (-f $ini_file){
       print "[test suite ini file - $ini_file]\n\n";
        open F, $ini_file or confess "can't open $ini_file to read: $!";
        print join "", <F>;
        close F;
    }else{
       print "test suite ini file: not found\n"
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


sub check_set {

    my $project  = shift or confess "usage: check_set(*project,checkpoint,plugin,host)";
    my $cid      = shift or confess "usage: check_set(project,*checkpoint,plugin,host)";
    my $pid      = shift or confess "usage: check_set(project,checkpoint,plugin*,host)";
    my $host     = shift;


    confess "unknown project" unless  -d sparrow_root."/projects/$project";
    confess "unknown checkpoint" unless  -d sparrow_root."/projects/$project/checkpoints/$cid";


    if ($host){
        cp_set($project,$cid,'base_url',$host);
        print "checkpoint - set host to $host\n\n";
    }    

    my $ptype;

    if ($pid=~/(public|private)@/){
        $ptype = $1;
        $pid=~s/(public|private)@//;
    }
    
    if (! $ptype and -f sparrow_root."/plugins/public/$pid/sparrow.json" and -d sparrow_root."/plugins/private/$pid" ){
        warn "both public and private $pid plugin exists; choose `public\@$pid` or `private\@$pid` to overcome this ambiguity";
        return;
    }elsif( -f sparrow_root."/plugins/public/$pid/sparrow.json"  and $ptype ne 'private' ){
        cp_set($project,$cid,'plugin',"public\@$pid");
        print "checkpoint - set plugin to public\@$pid\n\n";
    }elsif( -d sparrow_root."/plugins/private/$pid/" and $ptype ne 'public'  ){
        cp_set($project,$cid,'plugin',"private\@$pid");
        print "checkpoint - set plugin to private\@$pid\n\n";
    }else{
        confess "plugin is not installed, you need to install it first to use in checkpoint";
    }    

}


sub check_ini {

    my $project  = shift or confess "usage: check_ini(*project,checkpoint)";
    my $cid      = shift or confess "usage: check_ini(project,*checkpoint)";

    confess "unknown project" unless  -d sparrow_root."/projects/$project";
    confess "unknown checkpoint" unless  -d sparrow_root."/projects/$project/checkpoints/$cid";
    confess "please setup your preferable editor via EDITOR environment variable\n" unless editor;

    exec editor.' '.sparrow_root."/projects/$project/checkpoints/$cid/suite.ini";

}

sub check_load_ini {

    my $project         = shift or confess "usage: check_load_ini(*project,checkpoint,path)";
    my $cid             = shift or confess "usage: check_load_ini(project,*checkpoint,path)";
    my $ini_file_path   = shift or confess "usage: check_load_ini(project,*checkpoint,path)";

    confess "unknown project" unless  -d sparrow_root."/projects/$project";
    confess "unknown checkpoint" unless  -d sparrow_root."/projects/$project/checkpoints/$cid";

    my $dest_path = sparrow_root."/projects/$project/checkpoints/$cid/suite.ini";
    copy($ini_file_path,$dest_path) or confess "Copy failed: $!";

    print "loaded test suite ini from $ini_file_path OK \n\n";

}


sub check_run {

    my $project  = shift or confess "usage: check_run(*project,checkpoint,options)";
    my $cid      = shift or confess "usage: check_run(project,*checkpoint,options)";
    my $options  = shift || '';

    confess "unknown project" unless  -d sparrow_root."/projects/$project";
    confess "unknown checkpoint" unless  -d sparrow_root."/projects/$project/checkpoints/$cid";

    my $cp_set = cp_get($project,$cid);

    confess "plugin not set" unless $cp_set->{'plugin'};

    my $pdir = sparrow_root."/plugins/".($cp_set->{'install_dir'});

    confess 'plugin not installed' unless -d $pdir;

    my $spj = plugin_meta($pdir);
    my $cmd;
    
    if ($spj->{engine} and $spj->{engine} eq 'generic'){
        my $ini_file_path = sparrow_root."/projects/$project/checkpoints/$cid/suite.ini";
        $cmd = 'cd '.$pdir.' && '."carton exec 'strun --root ./ ";
        $cmd.=" --ini $ini_file_path" if -f $ini_file_path;
        $cmd.=" --host $cp_set->{base_url}" if $cp_set->{'base_url'};
        $cmd.=" '"
    }else{
        my $ini_file_path = sparrow_root."/projects/$project/checkpoints/$cid/suite.ini";
        $cmd = 'cd '.$pdir.' && '."carton exec 'swat ./ ";
        $cmd.=" $cp_set->{base_url}";
        $cmd.=" --ini $ini_file_path" if -f $ini_file_path;
        $cmd.=" '"
    }

    
    if ($options=~/--cron/) {
        my $repo_file = sparrow_root.'/reports/report-'.$project.'-'.$cid.'-'.$$.'.txt';
        exec "( $cmd 1>$repo_file 2>\&1 && rm $repo_file  )  || ( cat $repo_file ; rm -v $repo_file; exit 1; )";
    } else {
        print "# running $cmd ...\n\n";
        exec $cmd;
    }

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

