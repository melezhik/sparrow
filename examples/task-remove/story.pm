run_story('project/create');
run_story('project/task/create', { task_exists => 0 } );
run_story('project/task/remove');
set_stdout('OK');
