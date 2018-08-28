package Sparrow::Commands::Index;

use strict;

use base 'Exporter';

use Sparrow::Constants;
use Sparrow::Misc;
use HTTP::Tiny;

use Carp;

our @EXPORT = qw{

    update_index
    update_custom_index
    index_summary

};


sub update_index {

    print 'get index updates from SparrowHub ... ';

    my $data = _get_http_resource(sparrow_hub_api_url().'/api/v1/index');
    open my $fh, ">", spi_file() or die "can't open ".(spci_file())." to write";
    print $fh $data;
    close $fh;
    print "OK\n";

};

sub update_custom_index {

    my $repo = sparrow_config()->{repo};

    if ($repo){
      print "get index updates from custom repo $repo ... ";
      my $data = _get_http_resource($repo);
      open my $fh, ">", spci_file() or die "can't open ".(spci_file())." to write";
      print $fh $data;
      close $fh;
      print "OK\n";
    }

};

sub _get_http_resource {

  my $url = shift;

  my $response = HTTP::Tiny->new()->get($url);
 
  die "Failed to fetch $url: $response->{status} $response->{reason}\n" unless $response->{success};

  return  $response->{content};

}

sub index_summary {

    print "[sparrow index summary]\n\n";
    execute_shell_command("ls -l ".spi_file);
    execute_shell_command("ls -l ".spci_file);
    execute_shell_command("ls -l ".spl_file);

};

1;
