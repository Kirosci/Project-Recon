#!/bin/bash

domain=$1

if [ -z "$2" ]; then
    timeout="30"
else
    timeout="$2"
fi

dir=$(head -1 $domain)
mkdir "$dir" 2> /dev/null

cp $domain $dir
cd $dir || exit 1

rm subdomains.txt 2> /dev/null
rm live_subdomains.txt 2> /dev/null

(
  cat "$domain" | assetfinder > assetfinder_subdomains.txt 2> /dev/null
  echo -e "    |---\e[32m[Assetfinder Done]\e[0m"
) &

(
  cat "$domain" | haktrails subdomains > haktrails_subdomains.txt 2> /dev/null
  echo -e "    |---\e[32m[Haktrails Done]\e[0m"
) &

(
  cat "$domain" | subfinder > subfinder_subdomains.txt 2> /dev/null
  echo -e "    |---\e[32m[Subfinder Done]\e[0m"
) &

(

  if [ "$2" -eq 1 ]; then
    amass enum -df "$domain" > amass_subdomains.txt 2> /dev/null
    echo -e "    |---\e[32m[Amass Done]\e[0m"

  elif [ "$2" -eq 0 ]; then
  echo -e "    |---\e[32m[Excluded Amass]\e[0m"
  cat "$domain" | tee amass_subdomains.txt 1&>2 /dev/null

  else
    amass enum -df "$domain" -timeout $timeout > amass_subdomains.txt 2> /dev/null
    echo -e "    |---\e[32m[Amass Done] [Timeout: $2 minutes]\e[0m" 
  fi

) &

(
  subdominator -dL "$domain" -o subdominator_subdomains.txt 1> /dev/null
  echo -e "    |---\e[32m[Subdominator Done]\e[0m" 
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
    grep -E "\\b${word//./\\.}\\b" "$file2" | awk '{print$1}' | sort -u | >> "subdomains.txt"
done < "$file1"

#---------------------------Organizing Assets---------------------------------------

rm assetfinder_subdomains.txt subdominator_subdomains.txt amass_subdomains.txt haktrails_subdomains.txt subfinder_subdomains.txt
#-----------------------------Finding Live Subdomains-------------------------------

cat subdomains.txt | httpx > live_subdomains.txt 2> /dev/null
# Use "chmod 777 script.sh" to give it permissions for soomth run

