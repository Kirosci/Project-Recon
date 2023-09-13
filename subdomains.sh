#!/bin/bash

read domain
dir=$domain
mkdir $dir

cd $dir

(
  echo "$domain" | assetfinder | tee assetfinder_subdomains.txt
) &

(
  echo "$domain" | haktrails subdomains | tee haktrails_subdomains.txt
) &

(
  echo "$domain" | subfinder | tee subfinder_subdomains.txt
) &

(
  amass enum -d "$domain" | tee amass_subdomains.txt
) &

python3 /home/kali/tools/knock/knockpy.py $domain | tee knockpy_full.txt
cat knockpy_full.txt | awk '{print $5}' | tee knockpy_subdomains.txt &

wait

#----------------------------Sorting Assets-----------------------------------------

cat assetfinder_subdomains.txt haktrails_subdomains.txt subfinder_subdomains.txt knockpy_subdomains.txt | sort -u | tee all_assets.txt

cat all_assets.txt | grep -i -F .$domain | awk '{print$1}' | sort -u | grep -i -F .$domain | awk '{print$1}' | tee subdomains.txt

#---------------------------Organizing Assets---------------------------------------

mkdir deep/
mv assetfinder_subdomains.txt haktrails_subdomains.txt subfinder_subdomains.txt knockpy_subdomains.txt all_assets.txt deep/  

#-----------------------------Finding Live Subdomains-------------------------------

cat subdomains.txt | httpx | tee live_subdomains.txt 

echo 'Subdomains Done'

# Use "chmod 777 script.sh" to give it permissions for soomth run
