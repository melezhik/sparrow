use lib 't/lib/';

use test;

print Dumper(cp_get('foo100','bar'));
print "OK\n";
