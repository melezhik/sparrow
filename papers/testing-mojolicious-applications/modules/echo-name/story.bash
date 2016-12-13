name=$(story_var name)

$project_root_dir/app.pl get '/echo-name?name='$name | perl -MJSON -e 'print decode_json(join "", <STDIN>)->{name}'

