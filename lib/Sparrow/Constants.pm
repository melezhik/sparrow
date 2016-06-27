package Sparrow::Constants;

use strict;

use base 'Exporter';

our @EXPORT = qw {
    spl_file
    spi_file
    sparrow_root
    sparrow_hub_api_url
    editor
};



sub spl_file () {  $ENV{SUDO_USER} ? "/home/$ENV{SUDO_USER}/sparrow.list" : "$ENV{HOME}/sparrow.list" };
sub spi_file () {  $ENV{SUDO_USER} ? "/home/$ENV{SUDO_USER}/sparrow.index" : "$ENV{HOME}/sparrow.index" };
sub sparrow_root () { "$ENV{HOME}/sparrow" };
sub sparrow_hub_api_url () { $ENV{sparrow_hub_api_url} || 'https://sparrowhub.org' };
sub editor () { $ENV{'EDITOR'} };

