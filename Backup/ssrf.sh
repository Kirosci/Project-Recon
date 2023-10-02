#!/bin/bash

domain=$1
link=$2
dir=$(head -1 $domain)

cd "$dir" || exit 1
rm redirects_ssrf.txt 2> /dev/null
rm all_ssrf.txt 2> /dev/null
echo "[Server: $link]"
file="urls.txt"

counter=1

while read -r line; do
  lc=$link?no=$counter
  qs=$(echo "$line" | grep = | qsreplace -a | qsreplace $lc | awk NF | tee -a all_ssrf_urls.txt)  # Use the counter in the query
  headers=$(curl -I -L "$qs" -k 2> /dev/null)
  location_header=$(echo "$headers" | grep -i "location:" 2> /dev/null)
  if [ -n "$location_header" ]; then
    url=$(echo "$location_header" | awk '{print $2}')
    echo "$qs ---> $url" | tee -a redirects_ssrf.txt
  fi

  counter=$((counter+1))
done < "$file"