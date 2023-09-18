#!/bin/bash

dir=$1
link=$2 

cd $dir
# cat a.txt | grep = | qsreplace -a | qsreplace $link | sort -u | httpx -fr | grep ']'

echo "[Server: $link]"
file="urls.txt"
while read -r line; do
  qs=$(echo "$line" | grep = | qsreplace -a | qsreplace $link )
  headers=$(curl -I "$qs" -k 2> /dev/null)
  location_header=$(echo "$headers" | grep -i "location:")

  if [ -n "$location_header" ]; then
  url=$(echo "$location_header" | awk '{print $2}')
  echo "$qs ---> $url"
  fi
done < "$file"
echo "Done! Press enter to continue"