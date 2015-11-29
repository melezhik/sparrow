package Sparrow::Commands::Swat;

use base 'Exporter';

use Sparrow::Constants;
use Sparrow::Misc;

use Carp;
use File::Basename;
use File::Copy;

our @EXPORT = qw{

    swat_setup
    check_site
};


sub swat_setup {

    my $project = shift or confess "usage: swat_setup(project,site)";
    my $sid = shift or confess "usage: swat_setup(project,site)";

    if (-d sparrow_root."/projects/$project/sites/$sid" ){
        confess "please setup your preferable editor via EDITOR environment variable\n" unless editor;
        exec editor.' '.sparrow_root."/projects/$project/sites/$sid/swat.my";
    }else{
        confess "site $sid does not exist at project $project. use `sparrow project $project add_side $sid \$base_url' to create a site \n\n";
    }

}


sub check_site {

    my $project = shift or confess "usage: check_site(project,site,plugin)";
    my $sid = shift or confess "usage: check_site(project,site,plugin)";
    my $pid = shift or confess "usage: check_site(project,site,plugin)";

    my $site_base_url = site_base_url($project,$sid);


    if ( -f sparrow_root."/projects/$project/sites/$sid/swat.my" ){
        copy( sparrow_root."/projects/$project/sites/$sid/swat.my", sparrow_root."/projects/$project/plugins/$pid");
    }

    exec "cd ".sparrow_root."/projects/$project/plugins/$pid && carton exec swat ./ $site_base_url";

}

1;

