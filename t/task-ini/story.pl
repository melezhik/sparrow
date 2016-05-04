use lib 't/lib/';

use test;

print `EDITOR=touch sparrow task ini foo100 bar`;

print "OK\n";
