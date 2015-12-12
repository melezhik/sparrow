
use Sparrow::Constants;

my $url = story_var('url');

my $s = `sparrow project check_set foo100 bar -u $url`;

-f sparrow_root."/projects/foo100/checkpoints/bar/base_url" 
    and $s.= "\ndirectory projects/foo100/checkpoints/bar/base_url exists\n";

set_stdout($s);
