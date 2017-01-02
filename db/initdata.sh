#!/bin/sh

for sheetid in {1..1000}; do
    sed "s/sheetid/$sheetid/" initdata.sql | mysql -ukousuan -pkousuan kousuan 
done
