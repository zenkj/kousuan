#!/bin/sh
cd `dirname $0`
mysql -ukousuan -pkousuan kousuan <createtable.sql
