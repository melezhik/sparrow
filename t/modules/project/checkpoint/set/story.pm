
use Sparrow::Constants;

my $url = story_var('url');
my $plugin = story_var('plugin');


`sparrow check set foo100 bar -u $url` if $url;
`sparrow check set foo100 bar -p $plugin` if $plugin;

set_stdout('OK');
