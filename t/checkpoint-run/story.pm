run_story('project/create');
run_story('project/checkpoint/create', { cp_exists => 0 } );
run_story('plg/install');
#run_story('project/checkpoint/set', { plugin => 'foo-test' });
run_story('project/checkpoint/set', { url => '127.0.0.1', plugin => 'foo-test' });

