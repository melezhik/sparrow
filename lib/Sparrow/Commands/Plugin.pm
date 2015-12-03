package Sparrow::Commands::Plugin;

use strict;

use base 'Exporter';

use Sparrow::Constants;
use Sparrow::Misc;

use Carp;
use File::Basename;
use File::Path;
use File::Spec;

use HTTP::Tiny;
use JSON;

our @EXPORT = qw{

    show_local_plugins    
    show_plugins

    install_plugin
    show_plugin
    update_plugin
    remove_plugin
};


use constant 'github_api_base_url' => 'https://api.github.com/repos'; 

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
        print "$p->{author}\@$p->{repo_id}\n";
    }
}

sub install_plugin {

    my $pid = shift or confess 'usage: install_plugin(plugin_id)';

    my ($author,$repo_id) = split '@', $pid;

    my $list = read_plugin_list('as_hash');


    if ($list->{$pid}){


        print "installing plugin $pid ...\n";
        print "fetching latest release info from github, it might takes for awhile ...\n";

        my $pdata = get_plugin_github_info($author,$repo_id);
        my $latest_version = $pdata->{latest}->{tag_name};

        confess "could not find latest version of plugin" unless $latest_version;

        print "latest version found is: $latest_version\n";

        if ( -d sparrow_root."/plugins/$author/$repo_id/versions/$latest_version"){
            print "skip git clone part, as it's already done ...\n";
            execute_shell_command('cd '.sparrow_root."/plugins/$author/$repo_id/versions/$latest_version && carton");
        }else{
            mkpath(sparrow_root."/plugins/$author/$repo_id/versions/");
            execute_shell_command(
                'cd '.sparrow_root."/plugins/$author/$repo_id/versions/ && 
                 git clone https://github.com/$author/$repo_id.git $latest_version && 
                 cd $latest_version && carton"
            );
        }
    
        # update symlink to latest version
        if ( stat sparrow_root."/plugins/$author/$repo_id/latest" ) {
            unlink(sparrow_root."/plugins/$author/$repo_id/latest");
            print "regenerating symlink to latest version ... \n";
        }    

        symlink File::Spec->rel2abs(sparrow_root."/plugins/$author/$repo_id/versions/$latest_version"),
                File::Spec->rel2abs(sparrow_root."/plugins/$author/$repo_id/latest") or
        confess "can't create symlink /plugins/$author/$repo_id/latest ==> /plugins/$author/$repo_id/versions/$latest_version";


    }else{
        confess "unknown plugin $pid";
    }

}
sub show_plugin {

    my $pid = shift or confess 'usage: show_plugin(plugin_id)';

    my ($author,$repo_id) = split '@', $pid;

        if (stat sparrow_root."/plugins/$author/$repo_id/"){
            print "plugin [$pid]\n";
            print "installed - YES\n";
            execute_shell_command("ls ".sparrow_root."/plugins/$author/$repo_id");
        }else{
            my $list = read_plugin_list('as_hash');
            if ($list->{$pid}){

                my $pdata = get_plugin_github_info($author,$repo_id);

                print "plugin [$pid]\n";
                print "installed - NO\n";
                print "latest version: ", ( $pdata->{latest}->{tag_name} || 'not found' )  , "\n";
                print "available versions: ";
                if ( @{$pdata->{releases}} ){
                    print join ", ", map {$_->{tag_name}} @{$pdata->{releases}};
                }else {
                    print "not found\n";
                }
                print "\n"; 
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
        push @list, { author => $foo[0], repo_id => $foo[1] } ;
        $list{$foo[0].'@'.$foo[1]} = { author => $foo[0], repo_id => $foo[1] };
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

sub get_plugin_github_info {

    my $author = shift or confess('usage: get_plugin_github_info(*author,repo_id)');
    my $repo_id = shift or confess('usage: get_plugin_github_info(author,*repo_id)');


    # get all releases

    my $url = github_api_base_url."/$author/$repo_id/releases";
    my $response = HTTP::Tiny->new->get($url);
    confess "Failed to GET $url" unless $response->{success};

    my $all_r = decode_json($response->{content});

    # get latest releas info
    # only if none zero releases counted
    # for repository

    my $lr = {};

    if (@{$all_r}) {
        my $url = github_api_base_url."/$author/$repo_id/releases/latest";
        my $response = HTTP::Tiny->new->get($url);
        confess "Failed to GET $url" unless $response->{success};

        $lr = decode_json($response->{content});
    }
    
    return {
        latest => $lr,
        releases => $all_r
    };
}

1;

