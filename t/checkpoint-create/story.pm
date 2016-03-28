run_story('project/create');
run_story('project/checkpoint/create', { cp_exists => 0 } );
set_stdout('OK');
