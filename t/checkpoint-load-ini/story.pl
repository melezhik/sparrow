use lib 't/lib/';

use test;

my $cmd = "sparrow check load_ini foo100 bar ".project_root_dir()."/suite.ini"; 
print `$cmd`;
print "OK\n";
