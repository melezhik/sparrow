
use Sparrow::Constants;

my $url = story_var('url');
my $plugin = story_var('plugin');

if ($plugin and $url){
    `sparrow check set foo100 bar $plugin  $url`;
}else{
    `sparrow check set foo100 bar $plugin`;
}

set_stdout('OK');
