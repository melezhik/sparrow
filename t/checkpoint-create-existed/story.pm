run_story('project/create');
run_story('project/checkpoint/create', { cp_exists => 0 } );
run_story('project/checkpoint/create', { cp_exists => 1 } );
set_stdout('OK');
