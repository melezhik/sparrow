package Sparrow::Constants;

use base 'Exporter';

our @EXPORT = qw {
    spl_file
    sparrow_root
    editor
};



sub spl_file () {  "$ENV{HOME}/sparrow/sparrow.list" };
sub sparrow_root () { "$ENV{HOME}/sparrow" };
sub editor () { $ENV{'EDITOR'} };

