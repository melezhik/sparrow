#!perl6

shell("ls -1 *.gz");

my $distro = prompt("enter distro name: ");

task-run "upload distro to cpan", "cpan-upload", %(
  distro => $distro,
  clean  => "on"
);
