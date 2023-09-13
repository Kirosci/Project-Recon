#!/bin/bash

read dir
cd $dir

(
cat live_subdomains.txt | waybackurls | tee wayback_urls.txt
) &

(
cat live_subdomains.txt | gau | tee gau_urls.txt 
) &

wait

cat wayback_urls.txt gau_urls.txt | sort -u |tee urls.txt &


#-------------------------------------URLs_Done------------------------------------------------

wait

mv gau_urls.txt wayback_urls.txt all_assets.txt deep/


#-----------------------------------------Organizing_Done---------------------------------------


clear

echo "Mission Completed Respect+"

tree $dir

