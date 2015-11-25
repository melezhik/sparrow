# SYNOPSIS
Sparrow - is a tiny monitoring tool based on swat tests.

# INSTALL

cpanm Sparrow


# USAGE


## create a project

    sparrow project foo create

## download necessary swat plugins

    sparrow plg list
    sparrow plg install nginx
    sparrow plg install tomcat

## attach plugins to project

    sparrow project foo add_plg nginx 
    sparrow project foo add_plg tomcat

## attach sites to project

    sparrow project foo add_site nginx_proxy 127.0.0.1
    sparrow project foo add_site tomcat_app 127.0.0.1:8080

## run swat tests

    sparrow project foo check_site nginx_proxy nginx
    sparrow project foo check_site tomcat_app nginx

## customize swat settings for site

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




