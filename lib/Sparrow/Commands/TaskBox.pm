package Sparrow::Commands::TaskBox;

use strict;

use base 'Exporter';

use Carp;
use JSON;
use Sparrow::Commands::Project;
use Sparrow::Commands::Task;
use Sparrow::Commands::Plugin;
use Sparrow::Constants;

our @EXPORT = qw{

    box_run

};

sub box_run {

    my $path = shift or confess 'usage box_run(path, opts)';

    my %opts = @_;

    my $quiet_mode = ( $opts{'--mode'} && $opts{'--mode'} eq 'quiet' ) ? 1 : 0;

    delete $opts{'--mode'};

    open JSON, $path or confess "can't open file $path to read: $!";

    my $json_str = join "", <JSON>;

    close  JSON;

    my $tasklist = decode_json $json_str;

    my %plg_seen;

    for my $task (@{$tasklist}){
      install_plugin($task->{plugin}) unless $plg_seen{$task->{plugin}}++;        
    }

    project_remove('taskbox', { quiet => $quiet_mode  });

    project_create('taskbox', { quiet => $quiet_mode });


    my $i=0;

    my %task_seen;

    for my $task (@{$tasklist}) {
      
      $i++;

      my $path = sparrow_root()."/cache/task_$i.json";

      open JSON, ">", $path or confess "can't open file $path to read: $!";

      print JSON encode_json($task->{data});

      close JSON;

      (my $safe_task_name = $task->{task})=~s/[^\w_-]/-/g;

      $safe_task_name.="_".$i if $task_seen{$safe_task_name}++;

      task_add('taskbox', $safe_task_name,$task->{plugin}, '--quiet', $quiet_mode, 'task_desc' , $task->{task} );


    }


    $i=0;

    print "running task box from $path ... \n";

    for my $task (@{$tasklist}){

      $i++;

      my $path = sparrow_root()."/cache/task_$i.json";

      (my $safe_task_name = $task->{task})=~s/[^\w_-]/-/g;

      #print "task_run $safe_task_name, $path\n";

      task_run('taskbox',$safe_task_name,'--no-exec', '--json', $path, %opts );

    }


}

1;

