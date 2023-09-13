#!/bin/bash

read domain
dir=$domain
mkdir $dir


(
  echo "$domain" | assetfinder | tee $dir/assetfinder_subdomains.txt
) &

(
  echo "$domain" | haktrails subdomains | tee $dir/haktrails_subdomains.txt
) &

(
  echo "$domain" | subfinder | tee $dir/subfinder_subdomains.txt
) &

(
  amass enum -d "$domain" | tee $dir/amass_subdomains.txt
) &

(
python3 /home/kali/tools/knock/knockpy.py $domain | tee $dir/knockpy_full.txt
) & 

wait

cat $dir/knockpy_full.txt | awk '{print $5}' | tee $dir/knockpy_subdomains.txt

#----------------------------Sorting Assets-----------------------------------------

cat $dir/assetfinder_subdomains.txt $dir/haktrails_subdomains.txt $dir/subfinder_subdomains.txt $dir/amass_subdomains.txt $dir/knockpy_subdomains.txt | sort -u | tee $dir/all_assets.txt

cat $dir/all_assets.txt | grep -i -F .$domain | awk '{print$1}' | sort -u | grep -i -F .$domain | awk '{print$1}' | tee $dir/subdomains.txt

#---------------------------Organizing Assets---------------------------------------

mv $dir/assetfinder_subdomains.txt $dir/haktrails_subdomains.txt $dir/subfinder_subdomains.txt $dir/amass_subdomains.txt $dir/knockpy_subdomains.txt $dir/all_assets.txt old/  

#-----------------------------Finding Live Subdomains-------------------------------

cat $dir/subdomains.txt | httpx | tee $dir/live_subdomains.txt 

echo 'Subdomains Done'

# Use "chmod 777 script.sh" to give it permissions for soomth run
