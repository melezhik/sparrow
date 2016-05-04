run_story('project/create');
run_story('project/task/create', { cp_exists => 0 } );
set_stdout('OK');
