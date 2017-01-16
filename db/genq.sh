#!/bin/sh

edir=`dirname $0`
edir=`cd $edir; pwd`
qdir=$edir/../data/q

mkdir -p $qdir
cd $qdir
lua $edir/genq.lua

