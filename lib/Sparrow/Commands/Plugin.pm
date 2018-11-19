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

use Archive::Extract;
use File::Path qw(rmtree);

use Cwd;

use File::Copy::Recursive qw(dircopy);

use File::Find;

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

sub install_plugin_deps {

    my $plg_src = shift;

    print "install deps for $plg_src ...\n";

    my $pip_command = 'pip';

    if ( -f "$plg_src/cpanfile" ){
      execute_shell_command("cd $plg_src && carton install");
    }

    if ( -f "$plg_src/Gemfile" ){
      execute_shell_command("cd $plg_src && bundle --path local");
    }

    if ( -f "$plg_src/requirements.txt"){
      open F, "$plg_src/sparrow.json" or confess "can't open file $plg_src/sparrow.json to read: $!";
      my $sp = join "", <F>;
      my $spj = decode_json($sp);
      close F;
      if ( $spj->{python_version} && $spj->{python_version} eq '3' ) {
        $pip_command = 'pip3'
      }
      execute_shell_command("cd $plg_src && $pip_command install -t ./python-lib -r requirements.txt --install-option \"--install-scripts=\$PWD/local/bin\"");
    }

}

sub install_plugin_recursive {

  my $path = shift or die "usage: install_plugin_recursive(\$path)";
  my $force = shift;

  die "directory [$path] does not exit" unless -d $path;

  find(\&wanted($force), $path);  


}

sub wanted {

  my $force = shift;

  my $file = $_;

  return unless $file eq 'sparrow.json';

  my @args = (".","--local");

  push @args, "--force" if $force;

  install_plugin(@args);

}


sub install_plugin {

    my $pid  = shift or confess 'usage: install_plugin(name,opts)';

    my @args = @_;

    my $version;
    my $recursive;
    my $local_install;
    my $force;

    my $args_st = GetOptionsFromArray(
        \@args,
        "local"             => \$local_install,
        "force"             => \$force,
        "install_deps"      => \$install_deps,
        "recursive"         => \$recursive,
        "version=s"         => \$version,
    );

    my $ptype;

    if ($pid=~/(public|private)@/){
        $ptype = $1;
        $pid=~s/(public|private)@//;
    }

    my $list = read_plugin_list('as_hash');

    if ($recursive and $local_install){ # install plugin from local source recursively 

      install_plugin_recursive($pid, $force);

    } elsif ( $local_install ) {  # install plugin from local source as a public plugin

      my $dir = $pid eq '.'  ? getcwd : $pid;

      open F, "$dir/sparrow.json" or confess "can't open file $dir/sparrow.json to read: $!";
      my $sp = join "", <F>;
      my $spj = decode_json($sp);
      close F;

      my $v = version->parse($spj->{version});
      $pid = $spj->{name};

      print "install public\@$pid version $v from local source\n";

      if (-f sparrow_root."/plugins/public/$pid/sparrow.json" ){
  
        open F, sparrow_root."/plugins/public/$pid/sparrow.json" or confess "can't open file to read: $!";
        my $sp = join "", <F>;
        my $spj = decode_json($sp);
        close F;
  
        my $inst_v  = version->parse($spj->{version}||'0.0.0');
  
        if ($inst_v >= $v and ! $force ){
            print "plugin is already istalled and has higher version: $inst_v\n";
            return;
        }
  
      }

      if ( -d sparrow_root()."/plugins/public/$pid" ){
        rmtree(sparrow_root()."/plugins/public/$pid") or die "can't remove dir: ".sparrow_root()."/plugins/public/$pid, error: $!";
      }

      mkdir(sparrow_root()."/plugins/public/$pid") or die "can't create dir: ".sparrow_root()."/plugins/public/$pid, error: $!";

      dircopy($dir,sparrow_root()."/plugins/public/$pid/");

      if ( -d sparrow_root()."/plugins/public/$pid/.git" ){
        rmtree(sparrow_root()."/plugins/public/$pid/.git") or die "can't remove dir: ".sparrow_root()."/plugins/public/$pid/.git, error: $!";
      }

      install_plugin_deps(sparrow_root."/plugins/public/$pid");

    } elsif (! $ptype && $list->{'public@'.$pid} && $list->{'private@'.$pid} && ! $ptype ){

        warn "both public and private $pid plugin exists; choose `sparrow plg install public\@$pid` or `sparrow plg install private\@$pid` to overcome this ambiguity";

        return;

    } elsif ( $list->{'public@'.$pid} and $ptype ne 'private' ) {

        if (! $version  and  -f sparrow_root."/plugins/public/$pid/sparrow.json" ){
  
            open F, sparrow_root."/plugins/public/$pid/sparrow.json" or confess "can't open file to read: $!";
            my $sp = join "", <F>;
            my $spj = decode_json($sp);
            close F;

            my $plg_v  = version->parse($list->{'public@'.$pid}->{version});
            my $inst_v = version->parse($spj->{version});

            if ($plg_v > $inst_v){

                print "upgrading public\@$pid from version $inst_v to version $plg_v ...\n";

                if ( -d sparrow_root()."/plugins/public/$pid" ){
                  rmtree(sparrow_root()."/plugins/public/$pid") or die "can't remove dir: ".sparrow_root()."/plugins/public/$pid, error: $!";
                }

                mkdir(sparrow_root()."/plugins/public/$pid") or die "can't create dir: ".sparrow_root()."/plugins/public/$pid, error: $!";

                my $data = get_http_resource( sparrow_hub_api_url()."/plugins/$pid-v$plg_v.tar.gz", agent => 'sparrow' );
                my $plg_file = sparrow_root."/plugins/public/$pid/$pid-v$plg_v.tar.gz";

                open my $fh, ">:raw", $plg_file or die "can't open $plg_file to write";
                print $fh $data;
                close $fh;

                Archive::Extract->new( archive => $plg_file )->extract( to => sparrow_root()."/plugins/public/$pid" ) 
                or die "can't extract file $plg_file to ".sparrow_root()."/plugins/public/$pid, error: $!";

                install_plugin_deps(sparrow_root."/plugins/public/$pid");

            } else {

                print "public\@$pid is uptodate ($inst_v)\n";

                install_plugin_deps(sparrow_root."/plugins/public/$pid") if $install_deps;
            }

        } else {

            my $v = $version ||  $list->{'public@'.$pid}->{version};
            my $vn = version->parse($v)->numify; 
            
            print "installing public\@$pid version $v ...\n";

            if ( -d sparrow_root()."/plugins/public/$pid" ){
              rmtree(sparrow_root()."/plugins/public/$pid") or die "can't remove dir: ".sparrow_root()."/plugins/public/$pid, error: $!";
            }

            mkdir(sparrow_root()."/plugins/public/$pid") or die "can't create dir: ".sparrow_root()."/plugins/public/$pid, error: $!";

            my $data = get_http_resource( sparrow_hub_api_url()."/plugins/$pid-v$vn.tar.gz", agent => 'sparrow' );
            my $plg_file = sparrow_root."/plugins/public/$pid/$pid-v$vn.tar.gz";

            open my $fh, ">:raw", $plg_file or die "can't open $plg_file to write";
            print $fh $data;
            close $fh;

            Archive::Extract->new( archive => $plg_file )->extract( to => sparrow_root()."/plugins/public/$pid" )
            or die "can't extract file $plg_file to ".sparrow_root()."/plugins/public/$pid, error: $!";

            install_plugin_deps(sparrow_root."/plugins/public/$pid");

        }
          
    } elsif ($list->{'private@'.$pid} and $ptype ne 'public' ) {

        print "installing private\@$pid ...\n";

        execute_shell_command("cd ".sparrow_root."/plugins/private/$pid && git pull");

        execute_shell_command("cd ".sparrow_root."/plugins/private/$pid && git config credential.helper 'cache --timeout=3000000'");

        install_plugin_deps(sparrow_root."/plugins/private/$pid");

    } else {

        execute_shell_command("git clone  ".($list->{'private@'.$pid}->{url}).' '.sparrow_root."/plugins/private/$pid");
    
        execute_shell_command("cd ".sparrow_root."/plugins/private/$pid && git config credential.helper 'cache --timeout=3000000'");                
    
        install_plugin_deps(sparrow_root."/plugins/private/$pid");
    
    } elsif ( -d sparrow_root()."/plugins/public/$pid/" ) {

      print "plugin ".sparrow_root()."/plugins/public/$pid/ installed locally, nothing to do here ...\n";

    } else {
        confess "unknown plugin";
    }

}

sub run_plugin {

    my $pid = shift or confess "usage: run_plugin(*plugin_name,parameters)";


    my @args = @_;

    my $verbose_mode  = 0; 

    my $dump_config_arg;
    my $format_arg = $ENV{OUTTHENTIC_FORMAT} || sparrow_config->{'format'} || 'default';
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

    my $cli_args;
    
    my $i=0;  
    for my $a (@args) {
      if ($a eq '--') {
        delete $args[$i];
        $cli_args = join ' ', delete @args[$i .. $#args];
        last;
      }
      $i++;
    }  
  
    
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
        warn "both public and private $pid plugin exists; choose `sparrow plg install public\@$pid` or `sparrow plg install private\@$pid` to overcome this ambiguity";
        return;
    } elsif($list->{'public@'.$pid} and $ptype ne 'private' ) {
      $pdir = sparrow_root."/plugins/public/$pid";
      confess 'plugin not installed' unless -d $pdir;
    } elsif ($list->{'private@'.$pid} and $ptype ne 'public' ) {
      $pdir = sparrow_root."/plugins/private/$pid";
      confess 'plugin not installed' unless -d $pdir;
    } elsif  ( -d sparrow_root."/plugins/public/$pid" ) {
      warn "plugin is not listed in the index, locally installed one?";
      $pdir = sparrow_root."/plugins/public/$pid";
    } else{
      confess "unknown plugin";
    }


    my $spj = plugin_meta($pdir);

    if ($spj->{sparrow_version}){
      # check sparrow version if it's defined at sparrow.json

      my $curr_sp_v  = version->parse($Sparrow::VERSION);
      my $req_sp_v   = version->parse($spj->{sparrow_version});

      if ($req_sp_v > $curr_sp_v){
        die "plugin require sparrow version: $req_sp_v, but you have: $curr_sp_v";
      };

    }

    my $cmd;

	  if ($^O  =~ 'MSWin') {
      $cmd = "cd $pdir && set PATH=%PATH%;%cd%/local/bin && set PERL5LIB=%cd%/local/lib/perl5;\%PERL5LIB% && set PYTHONPATH=%cd%/python-lib;%PYTHONPATH% && ";
    } else {
      $cmd = "cd $pdir && export PATH=\$PATH:\$PWD/local/bin && export PERL5LIB=\$PWD/local/lib/perl5:\$PERL5LIB && export PYTHONPATH=\$PWD/python-lib:\$PYTHONPATH && ";
    }

    if ($spj->{plugin_type} eq 'outthentic'){

  	  if ($^O  =~ 'MSWin') {
        $cmd.="  strun --root ./ --task \"[plg] $pid\"";
      } else {
        $cmd.="  strun --root ./ --task '[plg] $pid'";
      }

    }elsif ( $spj->{plugin_type} eq 'swat' ) {
      $cmd.="  swat ./ ";
    }else{
      confess "unsupported plugin type: $spj->{plugin_type}"
    }

    for my $rp (@runtime_params){
      $rp=~/(\S+?)=(.*)/;
      #warn $1; warn $2;
      my $k = $1; my $v = $2;
  	  if ($^O  =~ 'MSWin') {
        $cmd.= " --param $k=$v";
      } else {
        $cmd.= " --param $k='$v'";
      }
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

    $cmd.= " -- $cli_args" if $cli_args;

    if ($verbose_mode){
      print map {"# $_\n"} split /&&\s+/, $cmd;
      print "\n";
    }

	if ($^O  =~ 'MSWin') {
		system($cmd) == 0 or "die $!";
	} else {
		exec $cmd;
	}	
    
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
            print "public\@$pid plugin installed, but not found at sparrow index. is it locally installed plugin?\n";
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


    my $pid = shift or confess('usage: man_plugin(*plugin_name)');

    my $ptype;

    if ($pid=~/(public|private)@/){
        $ptype = $1;
        $pid=~s/(public|private)@//;
    }

    if (-d sparrow_root."/plugins/public/$pid" and $ptype ne 'private' ){
      my $pdir = sparrow_root."/plugins/public/$pid";
      my $spj = plugin_meta($pdir);
      my $readme_file = $spj->{doc}  || 'README.md';
      exec("cat ".sparrow_root."/plugins/public/$pid/$readme_file");
    } elsif (-d sparrow_root."/plugins/private/$pid" and $ptype ne 'public' ){
      my $pdir = sparrow_root."/plugins/private/$pid";
      my $spj = plugin_meta($pdir);
      my $readme_file = $spj->{doc}  || 'README.md';
      exec("cat ".sparrow_root."/plugins/private/$pid/$readme_file");
    } else {
      warn "plugin not found";
    }

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
        rmtree(sparrow_root()."/plugins/public/$pid") or die "can't remove dir: ".sparrow_root()."/plugins/public/$pid, error: $!";
        $rm_cnt++;
    }

    if (-d sparrow_root."/plugins/private/$pid" and $ptype ne 'public' ){
        print "removing private\@$pid ...\n";
        rmtree(sparrow_root()."/plugins/private/$pid") or die "can't remove dir: ".sparrow_root()."/plugins/private/$pid, error: $!";
        $rm_cnt++;
    }

    warn "plugin is not installed" unless $rm_cnt;

}

sub read_plugin_list {

    my @list;
    my %list;

    my $mode = shift || 'as_array';

    # read public plugins list first
    open F, spi_file() or confess "can't open ".spi_file()." to read - $!";

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
    my $unsecure_flag = $ENV{SPARROW_UNSECURE} ? "-k" : "";
    execute_shell_command(
        "curl $unsecure_flag -H 'sparrow-user: $cred->{user}' " .
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

