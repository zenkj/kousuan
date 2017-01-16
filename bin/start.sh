#!/bin/sh

export PATH=$HOME/openresty/run/nginx/sbin:$PATH
dir=`dirname $0`
dir=`cd $dir/..; pwd`
nginx -p $dir -c conf/nginx.conf
