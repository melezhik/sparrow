use lib 't/lib/';

use test;

my $d  = cp_get('foo100','bar');

print "base_url: $d->{base_url}\n";
print "plugin: $d->{plugin}\n";

print "OK\n";
