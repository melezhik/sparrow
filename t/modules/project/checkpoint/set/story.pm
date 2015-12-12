
use Sparrow::Constants;

my $url = story_var('url');
my $plugin = story_var('plugin');


`sparrow project check_set foo100 bar -u $url` if $url;
`sparrow project check_set foo100 bar -p $plugin` if $plugin;

set_stdout('OK');
