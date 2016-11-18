# How to upload a script to SparrowHub

This is informal response to David Farrell's article [How to upload a script to CPAN](http://perltricks.com/article/how-to-upload-a-script-to-cpan/).

Preamble: CPAN is great. This post in no way should be treated as Sparrow VS CPAN attempt. [Sparrow](https://metacpan.org/pod/Sparrow) is just an alternative method
to distribute your scripts. Ok, let's go.


So let’s say I’ve got this Perl script:

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
    
Notice I have called my script `story.pl`? This is a naming convention for sparrow scripts.

Ok, let's move on.


# Setup your distribution directory

All we need is to:

* create a story check file
* create a cpanfile to declare script dependencies
* create a plugin meta file
* optionally create README.md


## story check file

Sparrow scripts should be accompanied by a check file. It's just a text file with some patterns to match against stdout emitted by an executed script. For example:


    $ cat story.check  
    regexp: (bar|rab)

Here we just require that script yields into stdout one of two lines - `bar` or `rab`. That is it.

Sometimes we don't need to check script stdout , that's ok just leave the story.check file empty:


    $ echo > story.check


## cpanfile

As we have an external dependency (the DateTime module) let's put it in a cpanfile:


    $ cat cpanfile
    requires 'DateTime'


Sparrow uses carton to run script with dependencies. That is it.


## plugin meta file

In a plugin meta file one defines essential information required for script upload to SparrowHub. The structure is quite simple, 
there should be a JSON format file with these fields:

* name - a plugin name
* version - a plugin version
* description - short plugin description
* url - plugin web page url (optional)

In other words the sparrow meta file is the way to "convert" an existing script into sparrow plugin:


    $ cat sparrow.json
    {
        "name" : "bar-script",
        "version" : "0.0.1",
         "description" : "print bar or rab",
         "url" : "https://github.com/melezhik/bar-script"
    }
    
## Readme file

You might want to add some documentation to the script. Simply create a README.md file with documentation in markdown format:


    $ cat README.md

    # SYNOPSIS
    
    print `bar` or `rab`
    
    # INSTALL
    
        $ sparrow plg install bar-script
    
    # USAGE
    
        $ sparrow plg run bar-script
        
    
    # Author
    
    [Alexey Melezhik](melezhik@gmail.com)
    
    # Disclosure
    
    An initial script code borrowed from David Farrell article [How to upload a script to CPAN](http://perltricks.com/article/how-to-upload-a-script-to-cpan/)


Finally we have the following project structure:


    $ tree
    
    .
    ├── cpanfile
    ├── README.md
    ├── sparrow.json
    ├── story.check
    └── story.pl
    
    0 directories, 5 files
    

# Test script

To see that the script does what you want simply run [`strun`](https://metacpan.org/pod/Outthentic#Story-runner) inside the project root directory:

    $ carton # install dependencies
    $ carton exec strun


    / started
    
    bar
    ok      scenario succeeded
    ok      output match /(bar|rab)/
    STATUS  SUCCEED
    

Strun - is utility comes with Sparrow to run sparrow scripts, it is used by plugin developers.

# Upload script to Sparrowhub

Provided you have an account on SparrowHub, just do this:

    $ sparrow plg upload
    sparrow.json file validated ...
    plugin bar-script version 0.000001 upload OK
    
Now you can browse the script [information](https://sparrowhub.org/info/bar-script) at SparrowHub.

# Run script

To run the script you need to install and run it with the sparrow client:


    $ sparrow index update
    $ sparrow plg install bar-script
    $ sparrow plg run bar-script

![sparrow-bar-script.png](https://raw.githubusercontent.com/melezhik/screenshots/master/sparrow-bar-script.png)


# Further reading

* [sparrow](https://metacpan.org/pod/Sparrow) documentation
* [outthentic](https://metacpan.org/pod/Outthentic) documentation
