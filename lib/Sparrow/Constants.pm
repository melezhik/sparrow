package Sparrow::Constants;

use strict;

use base 'Exporter';

our @EXPORT = qw {
    spl_file
    spi_file
    spci_file
    sparrow_conf_file
    sparrow_root
    sparrow_hub_api_url
    editor
};


# sparrow configuration file
sub sparrow_conf_file () {  
  $ENV{SPARROW_CONF_PATH} || do { $ENV{SPARROW_ROOT} ? "$ENV{SPARROW_ROOT}/sparrow.yaml" : "$ENV{HOME}/sparrow.yaml" }
};

# sparrow index - for public plugins comes from SparrowHub
sub spi_file () {  $ENV{SPARROW_ROOT}  ? "$ENV{SPARROW_ROOT}/sparrow.index" : "$ENV{HOME}/sparrow.index" };

# sparrow custom index - for custom plugins comes from custom repository (see "repo" in sparrow ini file )
sub spci_file () {  $ENV{SPARROW_ROOT}  ? "$ENV{SPARROW_ROOT}/sparrow.custom.index" : "$ENV{HOME}/sparrow.custom.index" };

# sparrow list index - for private plugins comes from github repositories
sub spl_file () {  $ENV{SPARROW_ROOT}  ? "$ENV{SPARROW_ROOT}/sparrow.list" : "$ENV{HOME}/sparrow.list" };

sub sparrow_root () { $ENV{SPARROW_ROOT} || "$ENV{HOME}/sparrow" };

# SparrowHub API 
sub sparrow_hub_api_url () { $ENV{sparrow_hub_api_url} || 'https://sparrowhub.org' };

sub editor () { $ENV{'EDITOR'} };

1;
