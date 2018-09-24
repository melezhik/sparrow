run_story('project/create');
run_story('project/task/create', { task_exists => 0 } );
run_story('project/task/create', { task_exists => 1 } );
set_stdout('OK');
