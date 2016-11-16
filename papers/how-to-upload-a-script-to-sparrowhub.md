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

All we need is to:

* create story check file
* create a cpanfile to declare script dependencies
* create plugin meta file
* optionally create README.md


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

## cpanfile

As we have some external dependencies (DateTime module) let's describe one in cpanfile:

```
$ cat cpanfile
requires 'DateTime'
```

Sparrow users under the hood a carton to run script with dependencies. That is it.


## plugin meta file

Plugin meta file define essential infomation required for script upload to SparrowHub. The structure is quite simple, this should be JSON format file with some fields:


* name -  a plugin name
* version - plugin version
* description - short plugin desription
* url - plugin web page url (optioanl)

As sparrow script gets delivered as sparrow plugin these are parameters to be set:
```
{
    "name" : "bar-script",
    "version" : "0.0.1",
     "description" : "print bar or rab",
     "url" : "https://github.com/melezhik/bar-script"
}
```


