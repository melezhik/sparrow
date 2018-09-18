use inc::Module::Install;

# Define metadata
name           'Sparrow';
abstract       'Multipurposes scenarios manager';

all_from       'lib/Sparrow.pm';

# Specific dependencies

requires    'Outthentic'      => '0.4.0';
requires    'Term::ANSIColor' => '4.02';
requires    'Carton';
requires    'version';
requires    'JSON';
requires    'YAML';
requires    'swat' => '0.2.0';
requires    'File::Touch';
requires    'HTTP::Tiny';
requires    'IO::Socket::SSL';
requires    'Archive::Extract';
requires    'Archive::Tar';
license     'perl';

repository  'https://github.com/melezhik/sparrow';

install_script 'bin/sparrow';

WriteAll;


