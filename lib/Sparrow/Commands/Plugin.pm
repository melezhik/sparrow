package Sparrow::Commands::Plugin;

use strict;

use base 'Exporter';

use Sparrow::Constants;
use Sparrow::Misc;

use Carp;
use File::Basename;
use HTTP::Tiny;
use JSON;
use version;


use constant sparrow_box_api_url => 'http://127.0.0.1:3000';

our @EXPORT = qw{

    show_installed_plugins    
    show_plugins

    install_plugin
    show_plugin
    remove_plugin

    upload_plugin

};


sub show_installed_plugins {

    print "[installed sparrow plugins]\n\n";

    print "[public]\n\n";

    my $root_dir = sparrow_root.'/plugins/public';

    opendir(my $dh, $root_dir) || confess "can't opendir $root_dir: $!";

    for my $p (grep { ! /^\.{1,2}$/ } readdir($dh)){
        print basename($p),"\n";
    }

    closedir $dh;

    print "[private]\n\n";

    my $root_dir = sparrow_root.'/plugins/private';

    opendir(my $dh, $root_dir) || confess "can't opendir $root_dir: $!";

    for my $p (grep { ! /^\.{1,2}$/ } readdir($dh)){
        print basename($p),"\n";
    }

    closedir $dh;

}


sub show_plugins {

    my $list = read_plugin_list();

    print "[available sparrow plugins]\n\n";
    print "name | type | version | git url \n";

    for my $p (@{$list}){
        print "$p->{name} | $p->{type} | $p->{url} | $p->{version}  \n";
    }
}

sub install_plugin {

    my $pid     = shift or confess 'usage: install_plugin(name,type)';
    my $type    = shift;

    my $list = read_plugin_list('as_hash');

    if ($list->{'public@'.$pid} && $list->{'private@'.$pid} && ! $type){
        warn "both public and private $pid plugin found, use --private or --public flag to choose which you want to install";
        return;
    }elsif ($type) {

        confess 'type should be one of two: private|public' unless $type=~/--(private|local)$/;
        print "installing $type\@$pid ...\n";

    }elsif($list->{'public@'.$pid}) {

        if ( -f sparrow_root."/plugins/public/$pid/sparrow.json" ){

            open F, sparrow_root."/plugins/public/$pid/sparrow.json" or confess "can't open file to read: $!";
            my $sp = join "", <F>;
            my $spj = decode_json($sp);
            close F;

            my $plg_v  = version->parse($list->{'public@'.$pid}->{version});
            my $inst_v = version->parse($spj->{version});

            if ($plg_v > $inst_v){
                print "upgrading public\@$pid from version $inst_v to version $plg_v ...\n";
            }else{
                print "public\@$pid is uptodate ($inst_v)\n";
            }

        }else{

            my $v = $list->{'public@'.$pid}->{version};

            print "installing public\@$pid version $v ...\n";

            execute_shell_command("rm -rf ".sparrow_root."/plugins/public/$pid");
            execute_shell_command("mkdir ".sparrow_root."/plugins/public/$pid");
            execute_shell_command("cd ".sparrow_root."/plugins/public/$pid && curl -f -o $pid-v$v.tar.gz ".sparrow_box_api_url."/distros/$pid-v$v.tar.gz");
            execute_shell_command("cd ".sparrow_root."/plugins/public/$pid && tar -xzf $pid-v$v.tar.gz && carton");

        }
        
    }elsif($list->{'private@'.$pid}) {
        print "installing private\@$pid ...\n";
        if ( -d sparrow_root."/plugins/private/$pid" ){
            execute_shell_command("cd ".sparrow_root."/plugins/private/$pid && git pull");
            execute_shell_command("cd ".sparrow_root."/plugins/private/$pid && carton");
        }else{
            execute_shell_command("git clone  ".($list->{'private@'.$pid}->{url}).' '.sparrow_root."/plugins/private/$pid");
            execute_shell_command("cd ".sparrow_root."/plugins/private/$pid && carton");
        }

    }else{
        confess "unknown plugin type: $list->{type}";
    }


}
sub show_plugin {

    my $pid = shift or confess 'usage: show_plugin(plugin_name)';

        if (-d sparrow_root."/plugins/$pid"){
            my $list = read_plugin_list('as_hash');
            print "[plugin $pid] info\n";
            print "\tinstalled: YES\n";
            print "\tgit url: ",( $list->{$pid} ? $list->{$pid}->{url} : 'unknown' ) ,"\n";
            # execute_shell_command("cd ".sparrow_root."/plugins/$pid && git log -n 1 --pretty=oneline");
        }else{
            my $list = read_plugin_list('as_hash');
            if ($list->{$pid}){
                print "[plugin $pid] info\n";
                print "\tinstalled: NO\n";
                print "\tgit url:",$list->{$pid}->{url},"\n";
            }else{
                confess "unkown plugin $pid";
            }
        }
}

sub remove_plugin {

    my $pid = shift or confess('usage: remove_plugin(plugin_name)');

    if (-d sparrow_root."/plugins/$pid"){
        print "removing plugin $pid ...\n";
        execute_shell_command("rm -rf ".sparrow_root."/plugins/$pid/");
    }else{
        confess "plugin $pid is not installed";
    }

}

sub read_plugin_list {

    my @list;
    my %list;

    my $mode = shift || 'as_array';

    open F, spl_file or confess $!;

    while ( my $i = <F> ){
        chomp $i;
        next unless $i=~/\S+/;
        my @foo = split /\s+/, $i;
        push @list, { name => $foo[0], url => $foo[1], type => 'private' } ;
        $list{'private@'.$foo[0]} = { name => $foo[0], url => $foo[1], type => 'private' };
    }
    close F;

    my $index_url = sparrow_box_api_url.'/index';

    my $response = HTTP::Tiny->new->get($index_url);
 
    if ($response->{success}){
        for my $i (split "\n", $response->{content}){
            next unless $i=~/\S+/;
            my @foo = split /\s+/, $i;
            push @list, { name => $foo[0], version => $foo[1], type => 'public' } ;
            $list{'public@'.$foo[0]} = { name => $foo[0], version => $foo[1], type => 'public'  };
        } 
    }else{
        confess "bad response from $index_url\n$response->{status}\n$response->{reason}\n";
    }


    my $retval;

    if ($mode eq 'as_hash'){
        $retval = \%list;
    }else{
        $retval = \@list;
    }

    return $retval;

}

sub upload_plugin {

    execute_shell_command('tar --exclude=local --exclude=*.log  --exclude=log  --exclude-vcs -zcf /tmp/archive.tar.gz .' );
    execute_shell_command('curl -f -X POST '.sparrow_box_api_url.'/upload -F archive=@/tmp/archive.tar.gz');

}


1;

