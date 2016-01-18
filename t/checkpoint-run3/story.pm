run_story('project/create');
run_story('project/checkpoint/create');
run_story('plg/install');
run_story('project/checkpoint/set', { plugin => 'foo-generic' });

