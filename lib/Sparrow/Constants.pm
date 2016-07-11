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



sub spl_file () {  $ENV{SPARROW_ROOT}  ? "$ENV{SPARROW_ROOT}/sparrow.list" : "$ENV{HOME}/sparrow.list" };
sub spi_file () {  $ENV{SPARROW_ROOT}  ? "$ENV{SPARROW_ROOT}/sparrow.index" : "$ENV{HOME}/sparrow.index" };

sub sparrow_root () { $ENV{SPARROW_ROOT} || "$ENV{HOME}/sparrow" };

sub sparrow_hub_api_url () { $ENV{sparrow_hub_api_url} || 'https://sparrowhub.org' };
sub editor () { $ENV{'EDITOR'} };

1;
