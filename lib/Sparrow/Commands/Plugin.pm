package Sparrow::Commands::Plugin;

use strict;

use base 'Exporter';

use Sparrow::Constants;
use Sparrow::Misc;

use Carp;
use File::Basename;

our @EXPORT = qw{

    show_local_plugins    
    show_plugins

    install_plugin
    show_plugin
    update_plugin
    remove_plugin
};


sub show_local_plugins {

    print "locally installed swat plugins:\n\n";

    my $root_dir = sparrow_root.'/plugins';

    opendir(my $dh, $root_dir) || confess "can't opendir $root_dir: $!";

    for my $p (grep { ! /^\.{1,2}$/ } readdir($dh)){
        print basename($p),"\n";
    }

    closedir $dh;

}


sub show_plugins {

    my $list = read_plugin_list();

    print "sparrow plugins list:\n\n";

    for my $p (@{$list}){
        print "$p->{name} | $p->{url}\n";
    }
}

sub install_plugin {

    my $pid = shift;

    my $list = read_plugin_list('as_hash');


    if ($list->{$pid}){
        if (-d sparrow_root."/plugins/$pid"){
            confess("plugin $pid already installed!\n".
            "you should remove plugin first by `sparrow plg remove $pid` to reinstall it \n");
        }
        print "installing plugin $pid ...\n";
        execute_shell_command('cd '.sparrow_root."/plugins && git clone $list->{$pid}->{url} $pid && cd $pid && carton");
    }else{
        confess "unknown plugin $pid";
    }

}
sub show_plugin {

    my $pid = shift or confess 'usage: show_plugin(plugin_name)';

        if (-d sparrow_root."/plugins/$pid"){
            print "plugin [$pid] install OK.\n";
            execute_shell_command("cd ".sparrow_root."/plugins/$pid && git remote -v");
        }else{
            my $list = read_plugin_list('as_hash');
            if ($list->{$pid}){
                print "plugin [$pid] NOT installed. git url:",$list->{$pid}->{url},"\n";
            }else{
                confess "unkown plugin $pid";
            }
        }
}

sub update_plugin {

    my $pid = shift or confess('usage: update_plugin(plugin_name)');

    if (-d sparrow_root()."/plugins/$pid"){
        print "updating plugin $pid ...\n";
        execute_shell_command("cd ".(sparrow_root)."/plugins/$pid && git pull && carton");
    }else{
        confess "plugin $pid is not installed";
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
        push @list, { name => $foo[0], url => $foo[1] } ;
        $list{$foo[0]} = { name => $foo[0], url => $foo[1] };
    }
    close F;

    my $retval;

    if ($mode eq 'as_hash'){
        $retval = \%list;
    }else{
        $retval = \@list;
    }

    return $retval;

}


1;

