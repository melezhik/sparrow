use inc::Module::Install;

# Define metadata
name           'Sparrow';
abstract       'Sparrow - swat based monitoring tool';

all_from       'lib/Sparrow.pm';

# Specific dependencies

requires    'Carton';
requires    'HTTP::Tiny';

license     'perl';

repository  'https://github.com/melezhik/sparrow';

install_script 'bin/sparrow';

WriteAll;


