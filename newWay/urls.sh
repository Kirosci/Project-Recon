#!/bin/bash

read dir
cd $dir

(
cat live_subdomains.txt | waybackurls > wayback_urls.txt 
) &

(
cat live_subdomains.txt | gau > gau_urls.txt 
) &

wait

cat wayback_urls.txt gau_urls.txt | sort -u > urls.txt 2> /dev/null &

wait

#-------------------------------------URLs_Done------------------------------------------------


mv gau_urls.txt wayback_urls.txt deep/


#-----------------------------------------Organizing_Done---------------------------------------

echo "Mission Completed Respect+"

tree ../$dir

