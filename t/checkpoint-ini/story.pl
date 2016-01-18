use lib 't/lib/';

use test;

print `EDITOR=touch sparrow check ini foo100 bar`;
print "OK\n";
