#!/bin/bash
# read domain
# read dir
# # domain="$1"
# # dir=$(head -1 "$domain")
# # dir=/home/kali/tools/automation/gopro.com
# cd "$dir" || exit 1
# file="testurls.txt"
# cat "$file" | grep = | kxss | grep '>\|<\|"' | tee kxss.txt


read domain
dir=$(head -1 "$domain")
cd "$dir" || exit 1
file="testurls.txt"
cat "$file" | grep = | kxss | grep '>\|<\|"' | tee kxss.txt
