#!/bin/bash

read dir
cd $dir

echo "    |---[Waybackurls | GAU | Katana]"

(
    cat live_subdomains.txt | waybackurls > wayback_urls.txt 
) &

(
    cat live_subdomains.txt | gau > gau_urls.txt 
) &

(
    cat live_subdomains.txt | katana scan --depth 3 > katana_urls.txt 2> /dev/null
) &

wait

cat wayback_urls.txt gau_urls.txt katana_urls.txt | sort -u > urls.txt 2> /dev/null &

wait

#-------------------------------------URLs_Done------------------------------------------------


mv gau_urls.txt wayback_urls.txt katana_urls.txt deep/


#-----------------------------------------Organizing_Done---------------------------------------

echo "Mission Completed Respect+"

tree ../$dir

