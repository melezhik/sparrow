use Sparrow::Constants;

print `sparrow task add foo100 bar foo-generic`;

-d sparrow_root."/projects/foo100/tasks/bar" and print "directory projects/foo100/tasks/bar exists\n";

