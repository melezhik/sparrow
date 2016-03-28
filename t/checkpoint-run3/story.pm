run_story('project/create');
run_story('project/checkpoint/create', { cp_exists => 0 } );
run_story('plg-generic/install');
run_story('project/checkpoint/set', { plugin => 'foo-generic' });

