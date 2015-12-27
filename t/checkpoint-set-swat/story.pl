use lib 't/lib/';

use test;

print `EDITOR=touch sparrow check set_swat foo100 bar`;
print "OK\n";
