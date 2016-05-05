use inc::Module::Install;

# Define metadata
name           'Sparrow';
abstract       'Multipurposes scenarios manager';

all_from       'lib/Sparrow.pm';

# Specific dependencies

requires    'Outthentic' => '0.1.2';
requires    'Term::ANSIColor' => '4.02';
requires    'Carton';
requires    'version';
requires    'JSON';
license     'perl';

repository  'https://github.com/melezhik/sparrow';

install_script 'bin/sparrow';

WriteAll;


