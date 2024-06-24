#!/bin/bash


domainFile=$1

baseDir="$(pwd)"

GREEN="\e[32m"
RED="\e[31m"
RESET="${RESET}"

while IFS= read -r domain; do 

    dir="results/$domain"
    cd $dir
    rm subTakeovers.txt 2> /dev/null
    rm 404.txt 2> /dev/null

    # Read subdomains and filter out 404 ones
    cat "subdomains.txt" | httpx -mc 404 2> /dev/null | sed 's/https\?:\/\///' > 404.txt

    # Checking for cname of all filtered subdomains
    file="404.txt"
    while read -r line; do
    dig "$line" | grep -a "CNAME" | grep -a "$line" >> subTakeovers.txt 
    done <$file

    lines=$(wc -l subTakeovers.txt 2> /dev/null | awk '{print$1}')

    rm 404.txt


    # Go back to Project-Recon dir at last 
    cd $baseDir

done < $domainFile