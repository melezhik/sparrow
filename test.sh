#! /usr/bin/env perl

use File::Find;
use Cwd;

my $root = getcwd();

find( { wanted => \&wanted, no_chdir => 1 } , $ARGV[0]||'t/');

sub wanted  {

  return unless /story\.(pl|rb|bash)$/;

  return if /modules\//;

  (my $dir = $File::Find::dir)=~s{t/}{};

  my $cmd = "strun --purge-cache --root ./t --story $dir --format production";

  (system($cmd) == 0)  or die "$cmd failed";

}


