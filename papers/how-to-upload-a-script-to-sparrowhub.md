# How to upload a script to SparrowHub

This is informal response on David Farrell article [How to upload a script to CPAN](http://perltricks.com/article/how-to-upload-a-script-to-cpan/).

Preambula: CPAN is great. This post in no ways should be treated as Sparrow VS CPAN attempt. [Sparrow](https://metacpan.org/pod/Sparrow) is just an alternative method
to destribute your scripts. Ok, let' go.


So let’s say I’ve got this Perl script:

```
$ cat story.pl

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

Ok, let's move further.


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

Sparrow meta file is the way to "convert" existed scrip into sparrow plugin:

```
$ cat sparrow.json
{
    "name" : "bar-script",
    "version" : "0.0.1",
     "description" : "print bar or rab",
     "url" : "https://github.com/melezhik/bar-script"
}
```

## Readme file

You might want to some documentation to script. Simple create a README.md file in markdown format:

```
$ cat README.md

# SYNOPSIS

print `bar` or `rab`

# INSTALL

    $ sparrow plg install bar-script

# USAGE

    $ sparrow plg run bar-srcipt
    

# Author

[Alexey Melezhik](melezhik@gmail.com)

# Discloser

An initial script code borrowed from David Farrell article [How to upload a script to CPAN](http://perltricks.com/article/how-to-upload-a-script-to-cpan/)
```

So we end up with project structure:

```
$ tree

.
├── cpanfile
├── README.md
├── sparrow.json
├── story.check
└── story.pl

0 directories, 5 files

```


# Test script

To see that script does what you want simple run [`strun`](https://metacpan.org/pod/Outthentic#Story-runner) inside project root directory:

```
$ carton # install dependencines
$ carton exec strun


/ started

bar
ok      scenario succeeded
ok      output match /(bar|rab)/
STATUS  SUCCEED

```

Strun - is uitility comes with Sparrow to run sparrow scripts, it is used by plugin developres.

# Upload script to Sparrowhub

Provided you have an account on Sparrowhub, just do this:


```
$ sparrow plg upload
sparrow.json file validated ...
plugin bar-script version 0.000001 upload OK
```

# Run script

To run script you need to install it and run with sparrow client:

```
$ sparrow index update
$ sparrow plg install bar-script
$ sparrow plg run bar-script
```


![sparrow-bar-script.png](https://raw.githubusercontent.com/melezhik/screenshots/master/sparrow-bar-script.png)
