package Sparrow::Misc;

use base 'Exporter';
use Carp;

our @EXPORT = qw {
    execute_shell_command 
};


sub execute_shell_command {
    my $cmd = shift;
    confess "failed execute: $cmd" unless system($cmd) == 0;
}




