#!/bin/bash

dir="$1"
link="$2"

cd "$dir" || exit 1

echo "[Server: $link]"
file="urls.txt"
while read -r line; do
  qs=$(echo "$line" | grep = | qsreplace -a | qsreplace "$link")
  headers=$(curl -I "$qs" -k 2> /dev/null)
  location_header=$(echo "$headers" | grep -i "location:")

  if [ -n "$location_header" ]; then
    url=$(echo "$location_header" | awk '{print $2}')
    url=$(echo "$url" | xargs) # Remove leading and trailing whitespace
    link=$(echo "$link" | xargs) # Remove leading and trailing whitespace
    echo "URL: $url"
    echo "LINK: $link"
    echo "-------------------"
    if [ "$url" == "$link" ]; then
      echo "$qs ---> $url" | tee -a ssrf.txt
    fi
  fi
done < "$file"
