This is kinda response on David Farrell article [How to upload a script to CPAN](http://perltricks.com/article/how-to-upload-a-script-to-cpan/).


So let’s say I’ve got this Perl script:

```
$ cat story.pl

#!/usr/bin/env perl
use strict;
use warnings;
use DateTime;

my $text = 'bar';
my $dt = DateTime->now;

if ($dt->mon == 1 && $dt->day == 31) {
   $text = reverse $text;
}

print "$text\n";
exit 0;
```

Notice I have called my script `story.pl`? This is a name convention about sparrow scripts.

Ok, let's further.


# Setup your distribution directory

All we need is:

* create story check file
* plugin meta file
* cpanfile to declare script dependencies
* and optionally README.md


## story check file

Sparrow scripts should be accompanided a check files. It's just a text files with some patterns to match stdout comes from an executed sparrow script. For example:


```
$ cat story.check  
```






