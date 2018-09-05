package Sparrow::Commands::Index;

use strict;

use base 'Exporter';

use Sparrow::Constants;
use Sparrow::Misc;

use Carp;

our @EXPORT = qw{

    update_index
    update_custom_index
    index_summary

};


sub update_index {

	if ( -f sparrow_hub_api_url()."/index" ) {
		open my $fh1, sparrow_hub_api_url()."/index" or die "can't open ".(sparrow_hub_api_url()."/index")." to read";
		my $data = join "", <$fh1>;
		close $fh1;	
		open my $fh2, ">", spi_file() or die "can't open ".(spci_file())." to write";
		print $fh2 $data;
		close $fh2;
		print  spi_file()." updated OK from ".sparrow_hub_api_url()."\\index\n";
	} else {
	    my $data = get_http_resource(sparrow_hub_api_url().'/api/v1/index');
		open my $fh, ">", spi_file() or die "can't open ".(spci_file())." to write";
		print $fh $data;
		close $fh;
		print  spi_file()." updated OK from ".sparrow_hub_api_url()."\n";
		
	}

};

sub update_custom_index {

    my $repo = sparrow_config()->{repo};

    if ($repo){
      print "get index updates from custom repo $repo ... ";
      my $data = get_http_resource($repo);
      open my $fh, ">", spci_file() or die "can't open ".(spci_file())." to write";
      print $fh $data;
      close $fh;
      print "OK\n";
    }

};

sub index_summary {

    print "[sparrow index summary]\n\n";
    execute_shell_command("ls -l ".spi_file);
    execute_shell_command("ls -l ".spci_file);
    execute_shell_command("ls -l ".spl_file);

};

1;
