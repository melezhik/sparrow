package Sparrow::Commands::Index;

use strict;

use base 'Exporter';

use Sparrow::Constants;
use Sparrow::Misc;

use Carp;

our @EXPORT = qw{

    update_index
    index_summary

};


sub update_index {

    print "get index updates from SparrowHub ...\n";
    execute_shell_command("curl -k -L -f  -o ".spi_file.' '.sparrow_hub_api_url.'/api/v1/index')

};

sub index_summary {

    print "[sparrow index summary]\n\n";
    execute_shell_command("ls -l ".spi_file);
    execute_shell_command("ls -l ".spl_file);

};

