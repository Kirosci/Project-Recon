#!/bin/bash

read domain
dir=$(head -1 $domain)
cd $dir || exit 1
# Remove files if it exisits
rm subTakeovers.txt 2> /dev/null
rm 404.txt 2> /dev/null

# Read subdomains and filter out 404 ones
file="subdomains.txt"
cat $file | httpx -mc 404 2> /dev/null | sed 's/https\?:\/\///' > 404.txt

# Checking for cname of all filtered subdomains
file="404.txt"
while read -r line; do
dig "$line" | grep -a "CNAME" | grep -a "$line" >> subTakeovers.txt 
done <$file

