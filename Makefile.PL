use inc::Module::Install;

# Define metadata
name           'Sparrow';
abstract       'Sparrow - outthentic suites manager';

all_from       'lib/Sparrow.pm';

# Specific dependencies

requires    'Carton';
requires    'version';
requires    'JSON';
license     'perl';

repository  'https://github.com/melezhik/sparrow';

install_script 'bin/sparrow';

WriteAll;


