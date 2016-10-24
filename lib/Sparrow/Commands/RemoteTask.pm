package Sparrow::Commands::RemoteTask;

use strict;

use base 'Exporter';

use Sparrow::Constants;
use Sparrow::Misc;
use Sparrow::Commands::Plugin;
use Sparrow::Commands::Project;
use Sparrow::Commands::Task;

use Carp;
use File::Basename;
use File::Path;

use JSON;
use Data::Dumper;
use File::Copy;

use Term::ANSIColor;

our @EXPORT = qw{

    remote_task_upload
    remote_task_install
    remote_task_run
    remote_task_share
    remote_task_hide
    remote_task_list
    remote_task_public_list
    remote_task_remove

};


sub remote_task_upload {

    my $path = shift or confess "usage: remote_task_upload(*path,comment)";
    my $comment = shift;

    my ($project, $task) = split '/', $path;

    confess "unknown project" unless  -d sparrow_root."/projects/$project";
    confess "unknown task" unless  -d sparrow_root."/projects/$project/tasks/$task";

    my $task_set = task_get($project,$task);

    confess "plugin not set" unless $task_set->{'plugin'};

    my $plugin_name = $task_set->{plugin};

    my $pdir = sparrow_root."/plugins/".($task_set->{'install_dir'});

    confess 'plugin not installed' unless -d $pdir;

    my $plugin_name = $task_set->{plugin};
    s{.*@}[] for $plugin_name; # FIXME: only public plugins could be uploaded as remote tasks

    my $cred;

    if ($ENV{sph_user} and $ENV{sph_token}){
        $cred->{user} = $ENV{sph_user};
        $cred->{token} = $ENV{sph_token};
    } else {
        # or read from $ENV{HOME}/sparrowhub.json
        open F, "$ENV{HOME}/sparrowhub.json" or confess "can't open $ENV{HOME}/sparrowhub.json to read: $!";
        my $s = join "", <F>;
        close F;
        $cred = decode_json($s);
    }


    my $suite_ini_path = sparrow_root."/projects/$project/tasks/$task/suite.ini";

    execute_shell_command(
        "curl -f -H 'sparrow-user: $cred->{user}' " .
        "-H 'sparrow-token: $cred->{token}' " .sparrow_hub_api_url().'/api/v1/remote-task/upload '.
         "-d project_name='$project' ".
         "-d task_name='$task' ".
         "-d plugin_name='$plugin_name' ",
        silent => 1 ,
    );
    print "\n";

    execute_shell_command(
        "curl -f -H 'sparrow-user: $cred->{user}' " .
        "-H 'sparrow-token: $cred->{token}' " .sparrow_hub_api_url().'/api/v1/remote-task/load-ini'.
         "/$project/$task/ ".
         "-F ini=\@$suite_ini_path ",
        silent => 1 ,
    );
    print "\n";
}


sub remote_task_list {

    my $cred;

    if ($ENV{sph_user} and $ENV{sph_token}){
        $cred->{user} = $ENV{sph_user};
        $cred->{token} = $ENV{sph_token};
    } else {
        # or read from $ENV{HOME}/sparrowhub.json
        open F, "$ENV{HOME}/sparrowhub.json" or confess "can't open $ENV{HOME}/sparrowhub.json to read: $!";
        my $s = join "", <F>;
        close F;
        $cred = decode_json($s);
    }

    my $out_path = sparrow_root()."/cache/".($cred->{user}).".remote_tasks.json";

    execute_shell_command(
        "curl -f -s -H 'sparrow-user: $cred->{user}' " .
        "-H 'sparrow-token: $cred->{token}' -o $out_path " .
        sparrow_hub_api_url().'/api/v1/remote-task/list',
        silent => 1 ,
    );

    open my $fh, $out_path or die "can't $out_path to read: $!";
    my $json_str = join "", <$fh>;
    close $fh;

    for my $t (@{decode_json($json_str)}){
      my $access = $t->{public_access} ? 'public' : 'private';
      print "$t->{t} $access\t$t->{project_name}/$t->{task_name}\n"
    }   
    print "\n";
}

sub remote_task_public_list {

    my $out_path = sparrow_root()."/cache/remote_tasks_public.json";

    execute_shell_command(
        "curl -f -s -o $out_path " .
        sparrow_hub_api_url().'/api/v1/remote-task/public-list',
        silent => 1 ,
    );

    open my $fh, $out_path or die "can't $out_path to read: $!";
    my $json_str = join "", <$fh>;
    close $fh;

    for my $t (@{decode_json($json_str)}){
      my $access = $t->{public_access} ? 'public' : 'private';
      print "$t->{t} $t->{owner}\@$t->{project_name}/$t->{task_name}\n"
    }   
    print "\n";
}

sub remote_task_share {
  remote_task_change_access(@_,'share');
}

sub remote_task_hide {
  remote_task_change_access(@_,'hide');
}

sub remote_task_change_access {

    my $path = shift or confess "usage: remote_task_change_access(path*,action)";
    my $action = shift or confess "usage: remote_task_change_access(path,*action)";

    my ($project, $task) = split '/', $path;

    my $cred;

    if ($ENV{sph_user} and $ENV{sph_token}){
        $cred->{user} = $ENV{sph_user};
        $cred->{token} = $ENV{sph_token};
    } else {
        # or read from $ENV{HOME}/sparrowhub.json
        open F, "$ENV{HOME}/sparrowhub.json" or confess "can't open $ENV{HOME}/sparrowhub.json to read: $!";
        my $s = join "", <F>;
        close F;
        $cred = decode_json($s);
    }


    execute_shell_command(
        "curl -f -X POST -H 'sparrow-user: $cred->{user}' " .
        "-H 'sparrow-token: $cred->{token}' " .sparrow_hub_api_url().'/api/v1/remote-task/'.
        "$action/$project/$task",
        silent => 1 ,
    );

    print "\n";
}

sub remote_task_remove {

    my $path = shift or confess "usage: remote_task_remove(path*)";

    my ($project, $task) = split '/', $path;

    my $cred;

    if ($ENV{sph_user} and $ENV{sph_token}){
        $cred->{user} = $ENV{sph_user};
        $cred->{token} = $ENV{sph_token};
    } else {
        # or read from $ENV{HOME}/sparrowhub.json
        open F, "$ENV{HOME}/sparrowhub.json" or confess "can't open $ENV{HOME}/sparrowhub.json to read: $!";
        my $s = join "", <F>;
        close F;
        $cred = decode_json($s);
    }


    execute_shell_command(
        "curl -f -X POST -H 'sparrow-user: $cred->{user}' " .
        "-H 'sparrow-token: $cred->{token}' " .sparrow_hub_api_url().'/api/v1/remote-task/remove/'.
        "$project/$task",
        silent => 1 ,
    );

    print "\n";
}

sub remote_task_install {

    my $path = shift or confess "usage: remote_task_install(path*,opts)";
    my %opts = @_;

    my ($project, $task) = split '/', $path;
    
    my $cred;

    my $out_path = sparrow_root()."/cache/meta/$path.json";
    my $ini_path = sparrow_root()."/cache/meta/$path.ini";

    if ($project =~ s/^(\S+)@//){

        my $owner = $1;

        execute_shell_command(
            "mkdir -p ".(sparrow_root())."/cache/meta/$owner\@$project && ".
            "curl -f -s ". sparrow_hub_api_url().'/api/v1/remote-task/meta/'.
            "$owner/$project/$task -o $out_path",
            silent => 1 ,
        );

    } else {
      if ($ENV{sph_user} and $ENV{sph_token}){
          $cred->{user} = $ENV{sph_user};
          $cred->{token} = $ENV{sph_token};
      } else {
          # or read from $ENV{HOME}/sparrowhub.json
          open F, "$ENV{HOME}/sparrowhub.json" or confess "can't read $ENV{HOME}/sparrowhub.json : $!";
          my $s = join "", <F>;
          close F;
          $cred = decode_json($s);
      }

      my $owner = $cred->{user};

      execute_shell_command(
          "mkdir -p ".(sparrow_root())."/cache/meta/$project && ".
          "curl -f -s -H 'sparrow-user: $cred->{user}' " .
          "-H 'sparrow-token: $cred->{token}' " .sparrow_hub_api_url().'/api/v1/remote-task/meta/'.
          "$owner/$project/$task -o $out_path",
          silent =>  1,
      );

    }

    print "task meta data saved to $out_path ...\n";

    open META, $out_path or confess "can't read $out_path : $!";
    my $str = join "", <META>;
    close META;
    my $meta = decode_json($str);

    open INI, "> $ini_path" or confess "can't write to $ini_path : $!";
    print INI $meta->{suite_ini};
    close INI;

    install_plugin($meta->{plugin_name});
    project_create($meta->{project_name});
    task_add($meta->{project_name},$meta->{task_name},$meta->{plugin_name});
    task_load_ini($meta->{project_name},$meta->{task_name},$ini_path);
    if ($opts{run}){
      task_run($meta->{project_name},$meta->{task_name});
    } else{
      print "\n\nnow you can ran task by: \$ sparrow task run $meta->{project_name} $meta->{task_name}\n\n";
    }
}

sub remote_task_run {
    remote_task_install(@_, 'run' => 1);
}

1;

