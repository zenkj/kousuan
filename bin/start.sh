#!/bin/sh

OPENRESTY_HOME=$HOME/openresty/run
dir=`dirname $0`
dir=`cd $dir/..; pwd`
$OPENRESTY_HOME/nginx/sbin/nginx -p $dir -c conf/nginx.conf
