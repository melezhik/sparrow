run_story('project/create');
run_story('plg-generic/install');
run_story('project/task/create', { task_exists => 0 } );

