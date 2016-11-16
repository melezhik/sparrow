# How to upload a script to SparrowHub

This is not formal response on David Farrell article [How to upload a script to CPAN](http://perltricks.com/article/how-to-upload-a-script-to-cpan/).

Preambula: CPAN is great. This post in now ways should treated as Sparrow VS CPAN attempt. Sparrow is just an alternative method
to destribute your scripts. Ok, let' go.


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
regexp: (bar|rab)
```

Here we just require that script yeilds into stdout one of two lines - `bar` or `rab`. That is it.

Sometimes we don't need to check script stdout , that's ok just live story.check file empty:

```
$ touch story.check
```







