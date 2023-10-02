#!/bin/bash

read domain
dir=$(head -1 $domain)
if [ -d "$dir" ]; then
    file_count=1
    while [ -d "${dir}_${file_count}" ]; do
        file_count=$((file_count + 1))
    done  
    dir="${dir}_${file_count}"
fi
mkdir "$dir"

cp $domain $dir
cd $dir

(
  cat "$domain" | assetfinder > assetfinder_subdomains.txt 2> /dev/null
  echo -e "        |---\e[32mAssetfinder Done\e[0m"
) &

(
  cat "$domain" | haktrails subdomains > haktrails_subdomains.txt 2> /dev/null
  echo -e "     |---\e[32mHaktrails Done\e[0m"
) &

(
  cat "$domain" | subfinder > subfinder_subdomains.txt 2> /dev/null
  echo -e "      |---\e[32mSubfinder Done\e[0m"
) &

(
  amass enum -df "$domain" -timeout 10 > amass_subdomains.txt 2> /dev/null
  echo -e "    |---\e[32mAmass Done\e[0m"
) &

(
  subdominator -dL "$domain" -o subdominator_subdomains.txt 1> /dev/null
  echo -e "   |---\e[32mSubdominator Done" 
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

cat assetfinder_subdomains.txt subdominator_subdomains.txt amass_subdomains.txt haktrails_subdomains.txt subfinder_subdomains.txt | sort -u > all_assets.txt

# Filtering out false positives

file1="$domain"
file2="all_assets.txt"

while IFS= read -r word; do
    grep -E "\\b${word//./\\.}\\b" "$file2" >> "subdomains.txt"
done < "$file1"

#---------------------------Organizing Assets---------------------------------------

mkdir deep/
mv assetfinder_subdomains.txt subdominator_subdomains.txt amass_subdomains.txt haktrails_subdomains.txt subfinder_subdomains.txt all_assets.txt deep/
#-----------------------------Finding Live Subdomains-------------------------------

cat subdomains.txt | httpx > live_subdomains.txt 2> /dev/null


# Use "chmod 777 script.sh" to give it permissions for soomth run

