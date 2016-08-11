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

    my $path = shift or confess 'usage box_run(path)';

    open JSON, $path or confess "can't open file $path to read: $!";

    my $json_str = join "", <JSON>;

    close  JSON;

    my $tasklist = decode_json $json_str;

    for my $task (@{$tasklist}){
      install_plugin($task->{plugin})        
    }

    project_remove('taskbox');

    project_create('taskbox');


    my $i=0;

    for my $task (@{$tasklist}) {
      
      $i++;

      my $path = sparrow_root()."/cache/task_$i.json";

      open JSON, ">", $path or confess "can't open file $path to read: $!";

      print JSON encode_json($task->{data});

      close JSON;

      (my $safe_task_name = $task->{task})=~s/[^\w_-]/-/g;

      task_add('taskbox',$safe_task_name,$task->{plugin});


    }


    $i=0;

    for my $task (@{$tasklist}){

      $i++;

      print "$task->{task}\n";

      my $path = sparrow_root()."/cache/task_$i.json";

      (my $safe_task_name = $task->{task})=~s/[^\w_-]/-/g;

      task_run('taskbox',$safe_task_name,"--json",$path);

    }


}

1;

