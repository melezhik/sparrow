package Sparrow::Commands::Plugin;

use strict;

use base 'Exporter';

use Sparrow::Constants;
use Sparrow::Misc;

use Carp;
use File::Basename;
use JSON;
use version;
use Getopt::Long qw(GetOptionsFromArray);

our @EXPORT = qw{

    search_plugins

    show_installed_plugins    

    install_plugin

    show_plugin

    man_plugin 

    remove_plugin

    run_plugin

    upload_plugin

    plugin_meta

};


sub search_plugins {

    my $pattern  = shift || '.*';

    my $list = read_plugin_list();

    print "[found sparrow plugins]\n\n";
    print "type    name\n\n";
    

    my $re = qr/$pattern/; 
    for my $p (grep { $_->{name}=~ $re }   @{$list}){
        print "$p->{type}\t$p->{name}\n";
    }
}


sub show_installed_plugins {

    print "[installed sparrow plugins]\n\n";

    print "[public]\n\n";

    my $root_dir = sparrow_root.'/plugins/public';

    opendir(my $dh, $root_dir) || confess "can't opendir $root_dir: $!";

    for my $p (grep { ! /^\.{1,2}$/ } readdir($dh)){
        print basename($p),"\n";
    }

    closedir $dh;

    print "\n\n[private]\n\n";

    my $root_dir = sparrow_root.'/plugins/private';

    opendir(my $dh, $root_dir) || confess "can't opendir $root_dir: $!";

    for my $p (grep { ! /^\.{1,2}$/ } readdir($dh)){
        print basename($p),"\n";
    }

    closedir $dh;

}


sub install_plugin {

    my $pid  = shift or confess 'usage: install_plugin(name,opts)';
    my %opts = @_;

    my $ptype;

    if ($pid=~/(public|private)@/){
        $ptype = $1;
        $pid=~s/(public|private)@//;
    }

    my $list = read_plugin_list('as_hash');

    if (! $ptype && $list->{'public@'.$pid} && $list->{'private@'.$pid} && ! $ptype){
        warn "both public and private $pid plugin exists; 
choose `sparrow plg install public\@$pid` or `sparrow plg install private\@$pid`
to overcome this ambiguity";
        return;

    } elsif($list->{'public@'.$pid} and $ptype ne 'private' ) {

    if (! $opts{'--version'}  and  -f sparrow_root."/plugins/public/$pid/sparrow.json" ){

            open F, sparrow_root."/plugins/public/$pid/sparrow.json" or confess "can't open file to read: $!";
            my $sp = join "", <F>;
            my $spj = decode_json($sp);
            close F;

            my $plg_v  = version->parse($list->{'public@'.$pid}->{version});
            my $inst_v = version->parse($spj->{version});

            if ($plg_v > $inst_v){

                print "upgrading public\@$pid from version $inst_v to version $plg_v ...\n";

                execute_shell_command("rm -rf ".sparrow_root."/plugins/public/$pid");

                execute_shell_command("mkdir ".sparrow_root."/plugins/public/$pid");

                execute_shell_command("curl -k -s -w 'Download %{url_effective} --- %{http_code}' -f -o ".
                sparrow_root."/plugins/public/$pid/$pid-v$plg_v.tar.gz ".
                sparrow_hub_api_url()."/plugins/$pid-v$plg_v.tar.gz && echo");

                execute_shell_command("cd ".sparrow_root."/plugins/public/$pid && tar -xzf $pid-v$plg_v.tar.gz");

                if ( -f sparrow_root."/plugins/public/$pid/cpanfile" ){
                  execute_shell_command("cd ".sparrow_root."/plugins/public/$pid && carton install");
                }            

                if ( -f sparrow_root."/plugins/public/$pid/Gemfile" ){
                  execute_shell_command("cd ".sparrow_root."/plugins/public/$pid && bundle --path local");
                }                

                if ( -f sparrow_root."/plugins/public/$pid/requirements.txt" ){
                  execute_shell_command("cd ".sparrow_root."/plugins/public/$pid && pip install -t ./python-lib -r requirements.txt");
                }            

            }else{
                print "public\@$pid is uptodate ($inst_v)\n";
                if ( -f sparrow_root."/plugins/public/$pid/cpanfile" ){
                  execute_shell_command("cd ".sparrow_root."/plugins/public/$pid && carton install");
                }            
                if ( -f sparrow_root."/plugins/public/$pid/Gemfile" ){
                  execute_shell_command("cd ".sparrow_root."/plugins/public/$pid && bundle --path local");
                }                

                if ( -f sparrow_root."/plugins/public/$pid/requirements.txt" ){
                  execute_shell_command("cd ".sparrow_root."/plugins/public/$pid && pip install -t ./python-lib -r requirements.txt");
                }            

            }

        } else {

            my $v = $opts{'--version'} ||  $list->{'public@'.$pid}->{version};
            my $vn = version->parse($v)->numify; 
            
            print "installing public\@$pid version $v ...\n";

            execute_shell_command("rm -rf ".sparrow_root."/plugins/public/$pid");

            execute_shell_command("mkdir ".sparrow_root."/plugins/public/$pid");

            execute_shell_command("curl -k -s -w 'Download %{url_effective} --- %{http_code}' -f -o".
            sparrow_root."/plugins/public/$pid/$pid-v$vn.tar.gz ".
            sparrow_hub_api_url()."/plugins/$pid-v$vn.tar.gz && echo");

            execute_shell_command("cd ".sparrow_root."/plugins/public/$pid && tar -xzf $pid-v$vn.tar.gz");

            if ( -f sparrow_root."/plugins/public/$pid/cpanfile" ){
                execute_shell_command("cd ".sparrow_root."/plugins/public/$pid && carton install");
            }            
            if ( -f sparrow_root."/plugins/public/$pid/Gemfile" ){
              execute_shell_command("cd ".sparrow_root."/plugins/public/$pid && bundle --path local");
            }                

            if ( -f sparrow_root."/plugins/public/$pid/requirements.txt" ){
              execute_shell_command("cd ".sparrow_root."/plugins/public/$pid && pip install -t ./python-lib -r requirements.txt");
            }            

        }
        
    } elsif ($list->{'private@'.$pid} and $ptype ne 'public' ) {
        print "installing private\@$pid ...\n";
        if ( -d sparrow_root."/plugins/private/$pid" ){
            execute_shell_command("cd ".sparrow_root."/plugins/private/$pid && git pull");
            execute_shell_command("cd ".sparrow_root."/plugins/private/$pid && git config credential.helper 'cache --timeout=3000000'");                
            if ( -f sparrow_root."/plugins/private/$pid/cpanfile" ){
                execute_shell_command("cd ".sparrow_root."/plugins/private/$pid && carton install");
            }            
            if ( -f sparrow_root."/plugins/private/$pid/Gemfile" ){
              execute_shell_command("cd ".sparrow_root."/plugins/private/$pid && bundle --path local");
            }                

            if ( -f sparrow_root."/plugins/private/$pid/requirements.txt" ){
              execute_shell_command("cd ".sparrow_root."/plugins/private/$pid && pip install -t ./python-lib -r requirements.txt");
            }            

        }else{
            execute_shell_command("git clone  ".($list->{'private@'.$pid}->{url}).' '.sparrow_root."/plugins/private/$pid");
            execute_shell_command("cd ".sparrow_root."/plugins/private/$pid && git config credential.helper 'cache --timeout=3000000'");                
            if ( -f sparrow_root."/plugins/private/$pid/cpanfile" ){
                execute_shell_command("cd ".sparrow_root."/plugins/private/$pid && carton install");
            }            
            if ( -f sparrow_root."/plugins/private/$pid/Gemfile" ){
              execute_shell_command("cd ".sparrow_root."/plugins/private/$pid && bundle --path local");
            }

            if ( -f sparrow_root."/plugins/private/$pid/requirements.txt" ){
              execute_shell_command("cd ".sparrow_root."/plugins/private/$pid && pip install -t ./python-lib -r requirements.txt");
            }            

        }

    }else{
        confess "unknown plugin";
    }

}

sub run_plugin {

    my $pid = shift or confess "usage: run_plugin(*plugin_name,parameters)";


    my @args = @_;

    my $verbose_mode  = 0; 

    my $dump_config_arg;
    my $format_arg;
    my $debug_arg;
    my $purge_cache_arg;
    my $match_l_arg;
    my $cwd_arg;
    my $story_arg;
    my $ini_arg;
    my $yaml_arg;
    my $json_arg;
    my $nocolor_arg;
    my $args_file_arg;

    my @runtime_params;

    my $args_st = GetOptionsFromArray(
        \@args,
        "verbose"     => \$verbose_mode,
        "param=s"     => \@runtime_params,
        "dump-config" => \$dump_config_arg,
        "args-file=s" => \$args_file_arg,
        "purge-cache" => \$purge_cache_arg,
        "format=s"    => \$format_arg,
        "debug=i"     => \$debug_arg,
        "match_l=i"   => \$match_l_arg,
        "cwd=s"       => \$cwd_arg,
        "story=s"     => \$story_arg,
        "ini=s"       => \$ini_arg,
        "yaml=s"      => \$yaml_arg,
        "json=s"      => \$json_arg,
        "nocolor"     => \$nocolor_arg,
    );

    my $ptype; 

    my $pdir;

    if ($pid=~/(public|private)@/){
        $ptype = $1;
        $pid=~s/(public|private)@//;
    }

    my $list = read_plugin_list('as_hash');

    if (! $ptype && $list->{'public@'.$pid} && $list->{'private@'.$pid} && ! $ptype){
        warn "both public and private $pid plugin exists; 
choose `sparrow plg install public\@$pid` or `sparrow plg install private\@$pid`
to overcome this ambiguity";
        return;

    } elsif($list->{'public@'.$pid} and $ptype ne 'private' ) {
      $pdir = sparrow_root."/plugins/public/$pid";
      confess 'plugin not installed' unless -d $pdir;
    } elsif ($list->{'private@'.$pid} and $ptype ne 'public' ) {
      $pdir = sparrow_root."/plugins/private/$pid";
      confess 'plugin not installed' unless -d $pdir;
    }else{
        confess "unknown plugin";
    }


    my $spj = plugin_meta($pdir);

    my $cmd = "cd $pdir && export PATH=\$PATH:\$PWD/local/bin && export PERL5LIB=local/lib/perl5:\$PERL5LIB && export PYTHONPATH=python-lib:\$PYTHONPATH && ";

    if ($spj->{plugin_type} eq 'outthentic'){
      $cmd.="  strun --root ./ --task '[plg] $pid'";
    }elsif ( $spj->{plugin_type} eq 'swat' ) {
      $cmd.="  swat ./ ";
    }else{
      confess "unsupported plugin type: $spj->{plugin_type}"
    }

    for my $rp (@runtime_params){
      $rp=~/(\S+?)=(.*)/;
      #warn $1; warn $2;
      $cmd.= " --param $1='$2'";
    }


    $cmd.= " --nocolor" if $nocolor_arg;
    $cmd.= " --dump-config" if $dump_config_arg;
    $cmd.= " --purge-cache" if $purge_cache_arg;

    $cmd.= " --format $format_arg" if $format_arg;
    $cmd.= " --debug $debug_arg" if $debug_arg;
    $cmd.= " --match_l $match_l_arg" if $match_l_arg;

    $cmd.= " --ini $ini_arg" if $ini_arg;
    $cmd.= " --yaml $yaml_arg" if $yaml_arg;
    $cmd.= " --json $json_arg" if $json_arg;

    $cmd.= " --cwd $cwd_arg" if $cwd_arg;
    $cmd.= " --story $story_arg" if $story_arg;
    $cmd.= " --args-file $args_file_arg" if $args_file_arg;

    if ($verbose_mode){
      print map {"# $_\n"} split /&&\s+/, $cmd;
      print "\n";
    }

    exec $cmd;
}

sub show_plugin {

    my $pid = shift or confess 'usage: show_plugin(plugin_name)';

    my $list = read_plugin_list('as_hash');

    my $listed = ( $list->{'public@'.$pid} or $list->{'private@'.$pid} ) ? 1 : 0;

    if ($listed and $list->{'public@'.$pid} ) {

        my $inst_version = '';
        my $desc = '';

        if ( open F, sparrow_root."/plugins/public/$pid/sparrow.json" ){
            my $s = join "", <F>;
            close F;
            my $spj = decode_json($s);
            $inst_version = eval { version->parse($spj->{version})->numify };
            $desc = $spj->{description};
        } else {
            $inst_version = 'unknown';
            $desc = 'unknown';
        }

        print "\n";
        print "name: $pid\n";
        print "type: public\n";
        print "installed: ",(  -f sparrow_root."/plugins/public/$pid/sparrow.json"   ? 'YES':'NO'),"\n";
        print "version: ",$list->{'public@'.$pid}->{version},"\n";
        print "installed version: ",$inst_version,"\n" if -f sparrow_root."/plugins/public/$pid/sparrow.json";
        print "description: $desc\n";

    }

    if( $listed and $list->{'private@'.$pid} ) {
        print "\n";
        print "name: $pid\n";
        print "type: private\n";
        print "installed: ",( -d sparrow_root."/plugins/private/$pid/" ? 'YES':'NO'),"\n";
    }

    if (! $listed ) {
        if ( -f sparrow_root."/plugins/public/$pid/sparrow.json" ){
            print "public\@$pid plugin installed, but not found at sparrow index. is it obsolete plugin?\n";
        }
        if ( -d sparrow_root."/plugins/private/$pid" ){
            print "private\@$pid plugin installed, but not found at sparrow index. is it obsolete plugin?\n";
        }
        warn "unknown plugin" unless (
            -f sparrow_root."/plugins/public/$pid/sparrow.json" or
             -d sparrow_root."/plugins/private/$pid" 
        ); 
    }

}

sub man_plugin {

    my $pid = shift or confess 'usage: man_plugin(plugin_name)';

    # this should be changed in the future
    # as this trivial code
    # only dump a public plugin doc

    exec("cat ".sparrow_root."/plugins/public/$pid/README.md");


}

sub remove_plugin {

    my $pid = shift or confess('usage: remove_plugin(*plugin_name)');
    my $rm_cnt = 0;

    my $ptype;

    if ($pid=~/(public|private)@/){
        $ptype = $1;
        $pid=~s/(public|private)@//;
    }

    if (-d sparrow_root."/plugins/public/$pid" and $ptype ne 'private' ){
        print "removing public\@$pid ...\n";
        execute_shell_command("rm -rf ".sparrow_root."/plugins/public/$pid/");
        $rm_cnt++;
    }

    if (-d sparrow_root."/plugins/private/$pid" and $ptype ne 'public' ){
        print "removing private\@$pid ...\n";
        execute_shell_command("rm -rf ".sparrow_root."/plugins/private/$pid/");
        $rm_cnt++;
    }

    warn "plugin is not installed" unless $rm_cnt;

}

sub read_plugin_list {

    my @list;
    my %list;

    my $mode = shift || 'as_array';

    # read public plugins list first
    open F, spi_file() or confess "can't open ".spl_file()." to read - $!";

    while ( my $i = <F> ){
        chomp $i;
        next unless $i=~/\S+/;
        my @foo = split /\s+/, $i;
        push @list, { name => $foo[0], version => $foo[1], type => 'public' } ;
        $list{'public@'.$foo[0]} = { name => $foo[0], version => $foo[1], type => 'public'  };
    } 

    close F;

    # read custome plugins list then

    open F, spci_file() or confess "can't open ".spci_file()." to read";

    while ( my $i = <F> ){
        chomp $i;
        next unless $i=~/\S+/;
        next if $i=~/^\s*#/;
        my @foo = split /\s+/, $i;
        push @list, { name => $foo[0], url => $foo[1], type => 'private' } ;
        $list{'private@'.$foo[0]} = { name => $foo[0], url => $foo[1], type => 'private' };
    }

    close F;

    # read private plugins list at the end

    open F, spl_file() or confess "can't open ".spl_file()." to read";

    while ( my $i = <F> ){
        chomp $i;
        next unless $i=~/\S+/;
        next if $i=~/^\s*#/;
        my @foo = split /\s+/, $i;
        push @list, { name => $foo[0], url => $foo[1], type => 'private' } ;
        $list{'private@'.$foo[0]} = { name => $foo[0], url => $foo[1], type => 'private' };
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

sub upload_plugin {

    # get user/token by environment variables
    # usefull when making tests

    my $cred;

    if ($ENV{sph_user} and $ENV{sph_token}){
        $cred->{user} = $ENV{sph_user};
        $cred->{token} = $ENV{sph_token};
    }

    # or read from $ENV{HOME}/sparrowhub.json
    else{
        open F, "$ENV{HOME}/sparrowhub.json" or confess "can't open $ENV{HOME}/sparrowhub.json to read: $!";
        my $s = join "", <F>;
        close F;
        $cred = decode_json($s);
    }


    open F, 'sparrow.json' or confess "can't open sparrow.json to read: $!";
    my $s = join "", <F>;
    close F;

    my $spj = decode_json($s);

    # validating json file

    my $plg_v    = version->parse($spj->{version}) or confess "version not found in sparrow.json file";;
    my $plg_name = $spj->{name} or confess "name not found in sparrow.json file";

    $plg_name=~/^[\w\d-\._]+$/ or confess 'name parameter does not meet naming requirements - /^[\w\d-\._]+$/';

    print "sparrow.json file validated ... \n";

    execute_shell_command('tar --exclude=local --exclude=*.log  --exclude=log --exclude Gemfile.lock --exclude local/  --exclude-vcs -zcf /tmp/archive.tar.gz .' );
    execute_shell_command(
        "curl -H 'sparrow-user: $cred->{user}' " .
        "-H 'sparrow-token: $cred->{token}' " .
        '-f -X POST '.sparrow_hub_api_url().'/api/v1/upload -F archive=@/tmp/archive.tar.gz',
        silent => 1,
    );

}

sub plugin_meta {

    my $path = shift or confess('usage: plugin_meta(path)');

    open F, "$path/sparrow.json" or confess "can't open sparrow.json to read: $!";
    my $s = join "", <F>;
    close F;

    my $spj = decode_json($s);

    $spj->{plugin_type} ||= 'outthentic';

    return $spj;

}

1;

