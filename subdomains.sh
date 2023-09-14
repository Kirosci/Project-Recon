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
wait

# python3 ../knock/knockpy.py $domain | tee knockpy_full.txt
# cat knockpy_full.txt | awk '{print $5}' | tee knockpy_subdomains.txt &


# ========================================================================================
# -------------[IMPORTANT]----------------------
# Replace below line with LINE in "Sorting Assets section"
# cat assetfinder_subdomains.txt amass_subdomains.txt haktrails_subdomains.txt subfinder_subdomains.txt knockpy_subdomains.txt | sort -u | tee all_assets.txt
# ----------------------Replace the belo line with LINE in Organizing Assets----------------------------------
# mv assetfinder_subdomains.txt amass_subdomains.txt haktrails_subdomains.txt subfinder_subdomains.txt knockpy_subdomains.txt knockpy_full.txt all_assets.txt deep/  
# ========================================================================================




#----------------------------Sorting Assets-----------------------------------------

cat assetfinder_subdomains.txt amass_subdomains.txt haktrails_subdomains.txt subfinder_subdomains.txt | sort -u | tee all_assets.txt 1> /dev/null

cat all_assets.txt | grep -i -F .$domain | awk '{print$1}' | sort -u | grep -i -F .$domain | awk '{print$1}' | tee subdomains.txt 1> /dev/null

#---------------------------Organizing Assets---------------------------------------

mkdir deep/
mv assetfinder_subdomains.txt amass_subdomains.txt haktrails_subdomains.txt subfinder_subdomains.txt all_assets.txt deep/  1> /dev/null

#-----------------------------Finding Live Subdomains-------------------------------

cat subdomains.txt | httpx | tee live_subdomains.txt 1> /dev/null

echo 'Subdomains Done'

# Use "chmod 777 script.sh" to give it permissions for soomth run
