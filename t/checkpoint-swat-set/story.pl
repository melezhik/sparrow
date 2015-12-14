use lib 't/lib/';

use test;

print `EDITOR=touch sparrow project check_swat_set foo100 bar`;
print "OK\n";
