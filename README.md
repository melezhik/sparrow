# SYNOPSIS

Sparrow - is a tiny monitoring tool based on swat tests.

# FEATURES

* easy install and setup
* console client to setup and run swat test suites 
* ability to run tests remotely over rest API 
* custom plugin repositories support by design 

# INSTALL

cpanm Sparrow

# DEPENDENCIES 

curl, git, bash, swat

# USAGE


## create a project

*sparrow project $project_name create* - create a sparrow project, basically is a container to runs swat rests against different applications:

    sparrow project foo create


## download and install swat plugins

*sparrow plg install $plugin_name* - swat plugin is distributable swat test suite:

    sparrow plg list
    sparrow plg install nginx
    sparrow plg install tomcat


## attach plugins to project

*sparrow project $project_name add_plg $plugin_name* - swat project could contain one or more swat plugins:

    sparrow project foo add_plg nginx 
    sparrow project foo add_plg tomcat

## attach sites to project

*sparrow project $project_name add_site $site_name $base_url* - swat site - is a web application to run swat tests against. Base url parameter should be curl compliant:

    sparrow project foo add_site nginx_proxy http://127.0.0.1 
    sparrow project foo add_site tomcat_app 127.0.0.1:8080
    sparrow project foo add_site tomcat_app my.host/foo/bar

## run swat tests

*sparrow project $project_name check_site $site_name $plugin_name* - runs swat test suite against project's site:

    sparrow project foo check_site nginx_proxy nginx
    sparrow project foo check_site tomcat_app nginx

## customize swat settings for site

*sparrow project $project_name swat_setup $site_name $path_to_swat_ini_file* - setup swat ini file for given site:

    cat /path/to/swat.ini

        port=88
        debug=1

    sparrow project foo swat_setup nginx_proxy /path/to/swat.ini


## run swat tests remotely

    # runs sparrow rest API daemon
    sparrowd

    # runs swat tests over http call
    curl http://127.0.0.1:5090/foo/check_site/nginx_proxy/nginx


## misc

    # list installed plugins
    sparrow plg list --local


