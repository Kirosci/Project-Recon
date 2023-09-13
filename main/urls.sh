#!/bin/bash

read dir

(
cat $dir/live_subdomains.txt | waybackurls | tee $dir/wayback_urls.txt
) &

(
cat $dir/live_subdomains.txt | gau | tee $dir/gau_urls.txt 
) &

wait

cat $dir/wayback_urls.txt $dir/gau_urls.txt | sort -u |tee $dir/urls.txt &


#-------------------------------------URLs_Done------------------------------------------------


wait

mkdir $dir/deep

mv $dir/assetfinder_subdomains.txt $dir/haktrails_subdomains.txt $dir/subfinder_subdomains.txt $dir/amass_subdomains.txt $dir/knockpy_full.txt $dir/knockpy_subdomains.txt $dir/gau_urls.txt $dir/wayback_urls.txt $dir/all_assets.txt $dir/deep/


#-----------------------------------------Organizing_Done---------------------------------------


clear

echo "Mission Completed Respect+"

tree $dir

