#!/bin/bash

read domain
dir=$domain
mkdir $dir

cd $dir

(
  echo "$domain" | assetfinder > assetfinder_subdomains.txt 2> /dev/null
) &

(
  echo "$domain" | haktrails subdomains > haktrails_subdomains.txt 2> /dev/null
) &

(
  echo "$domain" | subfinder > subfinder_subdomains.txt 2> /dev/null
) &

(
  amass enum -d "$domain" > amass_subdomains.txt 2> /dev/null
) &

wait

# python3 ../knock/knockpy.py $domain > knockpy_full.txt
# cat knockpy_full.txt | awk '{print $5}' > knockpy_subdomains.txt &


# ========================================================================================
# -------------[IMPORTANT]----------------------
# Replace below line with LINE in "Sorting Assets section"
# cat assetfinder_subdomains.txt amass_subdomains.txt haktrails_subdomains.txt subfinder_subdomains.txt knockpy_subdomains.txt | sort -u > all_assets.txt
# ----------------------Replace the belo line with LINE in Organizing Assets----------------------------------
# mv assetfinder_subdomains.txt amass_subdomains.txt haktrails_subdomains.txt subfinder_subdomains.txt knockpy_subdomains.txt knockpy_full.txt all_assets.txt deep/  
# ========================================================================================




#----------------------------Sorting Assets-----------------------------------------

cat assetfinder_subdomains.txt amass_subdomains.txt haktrails_subdomains.txt subfinder_subdomains.txt | sort -u > all_assets.txt

cat all_assets.txt | grep -i -F .$domain | awk '{print$1}' | sort -u | grep -i -F .$domain | awk '{print$1}' > subdomains.txt 

#---------------------------Organizing Assets---------------------------------------

mkdir deep/
mv assetfinder_subdomains.txt amass_subdomains.txt haktrails_subdomains.txt subfinder_subdomains.txt all_assets.txt deep/

#-----------------------------Finding Live Subdomains-------------------------------

cat subdomains.txt | httpx > live_subdomains.txt  2> /dev/null


# Use "chmod 777 script.sh" to give it permissions for soomth run
