#!/bin/bash

read dir
cd $dir
touch a.txt
# Remove files if it exisits
rm subTakeovers.txt 2> /dev/null
rm 404.txt 2> /dev/null

# Read subdomains and filter out 404 ones
file="subdomains.txt"
cat $file | httpx -mc 404 | sed 's/https\?:\/\///' | tee 404.txt 1> /dev/null
clear

# Checking for cname of all filtered subdomains
file="404.txt"
echo "-----------------------Possible Subdomain Takeovers-----------------------------"
while read -r line; do
dig "$line" | grep -a "CNAME" | grep -a "$line" | tee -a subTakeovers.txt
done <$file
echo "Done"
