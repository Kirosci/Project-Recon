#!/bin/bash

read dir
# Remove files if it exisits
rm $dir/subTakeovers.txt 2> /dev/null
rm $dir/404.txt 2> /dev/null

# Read subdomains and filter out 404 ones
file="$dir/subdomains.txt"
cat $file | httpx -mc 404 | sed 's/https\?:\/\///' | tee $dir/404.txt 1> /dev/null
clear

# Checking for cname of all filtered subdomains
file="$dir/404.txt"
echo "-----------------------Possible Subdomain Takeovers-----------------------------"
while read -r line; do
dig "$line" | grep -a "CNAME" | grep -a "$line" | tee -a $dir/subTakeovers.txt
done <$file
rm $dir/404.txt
