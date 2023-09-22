#!/bin/bash

dir=$1
link=$2 

cd "$dir" || exit 1
rm redirects_ssrf.txt 2> /dev/null
rm all_ssrf.txt 2> /dev/null
echo "[Server: $link]"
file="urls.txt"

counter=1  # Initialize the counter

while read -r line; do
  lc=$link?no=$counter
  # echo $lc
  qs=$(echo "$line" | grep = | qsreplace -a | qsreplace $lc)  # Use the counter in the query  
  echo $qs | awk NF | tee -a all_ssrf.txt
  headers=$(curl -I "$qs" -k 2> /dev/null)
  location_header=$(echo "$headers" | grep -i "location:")

  if [ -n "$location_header" ]; then
    url=$(echo "$location_header" | awk '{print $2}')
    echo "$qs ---> $url" | tee -a redirects_ssrf.txt
  fi

  counter=$((counter+1))  # Increment the counter
done < "$file"
