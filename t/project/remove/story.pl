print `sparrow project remove foo100`;
print `sparrow project create foo100`;
print `sparrow project remove foo100`;

-d sparrow_root."/projects/foo100" or print "directory projects/foo100 removed\n";

print `sparrow project show foo100`;
