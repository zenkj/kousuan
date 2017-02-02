#!/bin/sh

OPENRESTY_HOME=/home/jzjian/openresty/run
dir=`dirname $0`
dir=`cd $dir/..; pwd`
$OPENRESTY_HOME/nginx/sbin/nginx -p $dir -c conf/nginx.conf
