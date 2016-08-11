package Sparrow::Commands::TaskBox;

use strict;

use base 'Exporter';

use Sparrow::Constants;
use Sparrow::Misc;
use Carp;
use JSON;

our @EXPORT = qw{

    box_run

};

sub box_run {

    my $path = shift or confess 'usage box_run(path)';

    open JSON, $path or confess "can't open file $path to read: $!";
    my $json_str = join "", <JSON>;
    close  JSON;
    my $json_data = decode_json $json_str;


}

1;

