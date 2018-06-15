package Sparrow::Commands::Task;

use strict;

use base 'Exporter';

use Sparrow::Constants;
use Sparrow::Misc;
use Sparrow::Commands::Plugin;

use Carp;
use File::Basename;
use File::Path;

use JSON;
use YAML;
use Config::General ;

use Data::Dumper;
use File::Copy;

use Term::ANSIColor;

use Getopt::Long qw(GetOptionsFromArray);

our @EXPORT = qw{

    task_list

    task_add
    task_show
    task_remove

    task_ini
    task_load_ini

    task_run

    task_get
    task_set

};

sub task_list {

    my %opts = map { $_ => 1 } @_;

    print "[sparrow task list]\n";
    
    my $root_dir = sparrow_root.'/projects/';

    opendir(my $dh, $root_dir) || confess "can't opendir $root_dir: $!";

    for my $p (sort { $a cmp $b } grep { ! /^\.{1,2}$/ } readdir($dh)){
        next unless -d "$root_dir/$p/tasks";
        my $project = basename($p);
        print " [", ( ( nocolor() || $opts{'--nocolor'} )  ? $project : colored(['blue on_yellow'],$project) ) ,"]\n";
        opendir(my $th, "$root_dir/$p/tasks") || confess "can't opendir $root_dir/$p: $!";
        for my $t (sort { $a cmp $b } grep { ! /^\.{1,2}$/ } readdir($th)){
          my $task = basename($t);
          print "  $p/$t\n";
        }
        closedir $th;
    }
    print "\n\n";
    closedir $dh;

}

sub task_add {

    my $project = shift or confess "usage: task_add(*project,task,plugin,opts)";
    my $tid     = shift or confess "usage: task_add(project,*task,plugin,opts)";
    my $pid     = shift or confess "usage: task_add(project,task,*plugin,opts)";
    my %opts    = @_;

    confess "unknown project" unless  -d sparrow_root."/projects/$project";

    $project=~/^[\w\d-\._]+$/ or confess 'project parameter does not meet naming requirements - /^[\w\d-\._]+$/';

    $tid=~/^[\w\d-\._]+$/ or confess 'task parameter does not meet naming requirements - /^[\w\d-\._]+$/';

    if  (-d sparrow_root."/projects/$project/tasks/$tid") {
      print "task $project/$tid already exists, update task parameters\n" unless $opts{'--quiet'};
    } else {
      mkdir sparrow_root."/projects/$project/tasks";
      mkdir sparrow_root."/projects/$project/tasks/$tid" or confess "can't create task directory: $!";
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
        my @task_args = ($project,$tid,'plugin',"public\@$pid");
        push @task_args, ('host', $opts{'--host'}) if $opts{'--host'};
        push @task_args, ('task_desc', $opts{task_desc} || $tid);
        task_set(@task_args);
        print "task - set plugin to public\@$pid\n" unless $opts{'--quiet'};
    }elsif( -d sparrow_root."/plugins/private/$pid/" and $ptype ne '--public'  ){
        my @task_args = ($project,$tid,'plugin',"private\@$pid");
        push @task_args, ('host', $opts{'--host'}) if $opts{'--host'};
        push @task_args, ('task_desc', $opts{task_desc} || $tid);
        task_set(@task_args);
        print "task - set plugin to private\@$pid\n" unless $opts{'--quiet'};
    }else{
        confess "plugin is not installed, you need to install it first to use in task";
    }    

    print "task $project/$tid successfully created\n" unless $opts{'--quiet'};

}

sub task_show {

    my $project  = shift or confess "usage: task_show(*project,task)";
    my $tid      = shift or confess "usage: task_show(project,*task)";

    confess "unknown project" unless  -d sparrow_root."/projects/$project";
    confess "unknown task" unless  -d sparrow_root."/projects/$project/tasks/$tid";


    print "[task $project/$tid]\n\n";

    local $Data::Dumper::Terse=1;
    print Dumper(task_get($project,$tid)), "\n\n";    

    my $ini_file = sparrow_root."/projects/$project/tasks/$tid/suite.cfg";
    my $ini_file_old = sparrow_root."/projects/$project/tasks/$tid/suite.ini"; 

    if (-f $ini_file){
       print "[configuration file - $ini_file]\n\n";
       open F, $ini_file or confess "can't open $ini_file to read: $!";
       print join "", <F>;
       close F;  
    }elsif ( -f $ini_file_old ) {
       print "[configuration file - $ini_file_old]\n\n";
       open F, $ini_file_old or confess "can't open $ini_file_old to read: $!";
       print join "", <F>;
       close F;  
    } else{
       print "configuration file does not exist\n"
    }


}

sub task_remove {

    my $project = shift or confess('usage: task_remove(*project,task)');
    my $tid     = shift or confess('usage: task_remove(project,*task)');

    $project=~/^[\w\d-\._]+$/ or confess 'project parameter does not meet naming requirements - /^[\w\d-\._]+$/';
    $tid=~/^[\w\d-\._]+$/ or confess 'task parameter does not meet naming requirements - /^[\w\d-\._]+$/';

    if (-d sparrow_root."/projects/$project" and -d sparrow_root."/projects/$project/tasks/$tid" ){
        rmtree( sparrow_root."/projects/$project/tasks/$tid" );
        print "task $project/$tid successfully removed\n";
    }else{
        warn "unknown task";
    }

}

sub task_ini {

    my $project  = shift or confess "usage: task_ini(*project,task)";
    my $tid      = shift or confess "usage: task_ini(project,*task)";

    confess "unknown project" unless  -d sparrow_root."/projects/$project";
    confess "unknown task" unless  -d sparrow_root."/projects/$project/tasks/$tid";
    confess "please setup your preferable editor via EDITOR environment variable\n" unless editor;

    my $cfg_file_path = sparrow_root."/projects/$project/tasks/$tid/suite.cfg";
    my $cfg_ini_file_path = sparrow_root."/projects/$project/tasks/$tid/suite.ini";

    if ( ! -f $cfg_file_path and -f  $cfg_ini_file_path ){
      copy($cfg_ini_file_path,$cfg_file_path) or confess "Copy failed: $!";
    }

    exec editor.' '.$cfg_file_path;

}

sub task_load_ini {

    my $project         = shift or confess "usage: task_load_ini(*project,task,path)";
    my $tid             = shift or confess "usage: task_load_ini(project,*task,path)";
    my $ini_file_path   = shift or confess "usage: task_load_ini(project,*task,path)";

    confess "unknown project" unless  -d sparrow_root."/projects/$project";
    confess "unknown task" unless  -d sparrow_root."/projects/$project/tasks/$tid";

    my $dest_path = sparrow_root."/projects/$project/tasks/$tid/suite.cfg";
    copy($ini_file_path,$dest_path) or confess "Copy failed: $!";

    print "loaded test suite ini from $ini_file_path OK \n";

}


sub task_run {

    my $project  = shift or confess "usage: task_run(*project,task,parameters)";
    my $tid      = shift or confess "usage: task_run(project,*task,parameters)";
    my @args     = @_; 

    my $cli_args;

    my $i=0;
    for my $a (@args) {
      if ($a eq '--') {
        delete $args[$i];
        $cli_args = join ' ', delete @args[$i .. $#args];
        last;
      }
      $i++;
    }

    my $verbose_mode     = 0; 
    my $noexec_mode      = 0;
    my $cron_mode        = 0;

    my $dump_config_arg;
    my $format_arg = $ENV{OUTTHENTIC_FORMAT} || sparrow_config->{'format'} || 'default';
    my $debug_arg;
    my $purge_cache_arg;
    my $match_l_arg;
    my $story_arg;
    my $ini_arg;
    my $yaml_arg;
    my $json_arg;
    my $nocolor_arg;
    my $args_file_arg;
    my $cwd_arg;

    my @runtime_params;

    my $args_st = GetOptionsFromArray(

        \@args,

        "verbose"     => \$verbose_mode,
        "no-exec"     => \$noexec_mode,
        "cron"        => \$cron_mode,
        "args-file=s" => \$args_file_arg,
        "param=s"     => \@runtime_params,
        "dump-config" => \$dump_config_arg,
        "purge-cache" => \$purge_cache_arg,
        "format=s"    => \$format_arg,
        "debug=i"     => \$debug_arg,
        "match_l=i"   => \$match_l_arg,
        "cwd=s"       => \$cwd_arg,
        "story=s"     => \$story_arg,
        "ini=s"       => \$ini_arg,
        "yaml=s"      => \$yaml_arg,
        "json=s"      => \$json_arg,
        "nocolor"     => \$nocolor_arg,

    );

    confess "unknown project" unless  -d sparrow_root."/projects/$project";
    confess "unknown task: ".(sparrow_root."/projects/$project/tasks/$tid") 
    unless  -d sparrow_root."/projects/$project/tasks/$tid";

    my $task_set = task_get($project,$tid);

    confess "plugin not set" unless $task_set->{'plugin'};

    my $pdir = sparrow_root."/plugins/".($task_set->{'install_dir'});

    confess 'plugin not installed' unless -d $pdir;

    my $spj = plugin_meta($pdir);
    
    my $cmd = "cd $pdir && export PATH=\$PATH:\$PWD/local/bin && export PERL5LIB=\$PWD/local/lib/perl5:\$PERL5LIB && export PYTHONPATH=\$PWD/python-lib:\$PYTHONPATH && ";

    if ($spj->{plugin_type} eq 'outthentic'){
      $cmd.="  strun --root ./ --task '[task] ".($task_set->{task_desc})."'"
    } elsif ( $spj->{plugin_type} eq 'swat' ) {
      $cmd.="  swat ./ ". ($task_set->{host}).' ';
    } else {
      confess "unsupported plugin type: $spj->{plugin_type}"
    }

    if ($yaml_arg){
      $cmd.=" --yaml $yaml_arg";
    } elsif ($json_arg){
      $cmd.=" --json $json_arg";
    } else {
      my $path = sparrow_root."/projects/$project/tasks/$tid/suite.cfg";
      if (-f $path and -s $path){
        OK: {

         open CFG, $path or die "cannot open file $path to read: $!";
         my $str = join "", <CFG>;
         close CFG;

         eval { decode_json($str) };
          $cmd.=" --json $path", last OK unless $@;
  
          eval { Load($str) };
          $cmd.=" --yaml $path", last OK unless $@;

          eval {

            Config::General->new(
              -InterPolateVars => 1 ,
              -InterPolateEnv  => 1 ,
              -ConfigFile      => $path 
            )->getall or confess "file $path is not valid config file";
  
          };

          $cmd.=" --ini $path", last OK unless $@;

          confess "bad configuration found at $path";

        }

      }else {
        my $path = sparrow_root."/projects/$project/tasks/$tid/suite.ini";
        $cmd.=" --ini $path" if -f $path and -s $path;
      }
    }

    for my $rp (@runtime_params){
      $rp=~/(\S+?)=(.*)/;
      #warn $1; warn $2;
      $cmd.= " --param $1='$2'";
    }


    $cmd.= " --nocolor" if $nocolor_arg;
    $cmd.= " --dump-config" if $dump_config_arg;
    $cmd.= " --purge-cache" if $purge_cache_arg;

    $cmd.= " --format $format_arg" if $format_arg;
    $cmd.= " --debug $debug_arg" if $debug_arg;
    $cmd.= " --match_l $match_l_arg" if $match_l_arg;

    $cmd.= " --cwd $cwd_arg" if $cwd_arg;
    $cmd.= " --story $story_arg" if $story_arg;
    $cmd.= " --args-file $args_file_arg" if $args_file_arg;

    $cmd.= " -- $cli_args" if $cli_args;

    if ($cron_mode) {
        my $repo_file = sparrow_root.'/cache/report-'.$project.'-'.$tid.'-'.$$.'.txt';
        exec "( $cmd 1>$repo_file 2>\&1 && rm $repo_file  )  || ( cat $repo_file ; rm -v $repo_file; exit 1; )";
    } else {

        if ($verbose_mode){
          print map {"# $_\n"} split /&&\s+/, $cmd;
          print "\n";
        }
        if ($noexec_mode){
          execute_shell_command($cmd);
        } else {
          exec $cmd
        }
    }

}


sub task_get {

    my $project = shift or confess "usage: task_get(*project,task)";
    my $tid     = shift or confess "usage: task_get(project,*task)";

    my $data;
    
    if (open F, sparrow_root."/projects/$project/tasks/$tid/settings.json") { 
        my $str = join "", <F>;
        close F;
        $data = decode_json($str);
        $data->{task_desc} ||= $tid;
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

sub task_set {

    my $project  = shift or confess "usage: task_set(*project,task,args)";
    my $tid      = shift or confess "usage: task_set(project,*task,args)";
    my %args     = @_;

    my $task_settings;

    open F, ">", sparrow_root."/projects/$project/tasks/$tid/settings.json" or 
        confess "can't open file to write: projects/$project/tasks/$tid/settings.json";

    for my $f (keys %args){
        $task_settings->{$f} = $args{$f};
    }

    print F encode_json($task_settings);
    close F;

}


sub nocolor { $ENV{SPARROW_NO_COLOR} }

1;

