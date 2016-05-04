run_story('project/create');
run_story('project/task/create', { task_exists => 0 } );

use lib 't/lib/';

use test;

my $cmd = "sparrow task load_ini foo100 bar ".project_root_dir()."/suite.ini";

set_stdout(`$cmd`);

set_stdout('OK');

my $f = sparrow_root().'/projects/foo100/tasks/bar/suite.ini';

open F, $f or die $!;
while (my $s = <F>){
    chomp $s;
    set_stdout($s);
}

close F;
