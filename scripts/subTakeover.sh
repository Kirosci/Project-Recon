#!/bin/bash

GREEN="\e[32m"
RED="\e[31m"
ORANGE="\e[38;5;214m"
RESET="\e[0m"

timeDate=$(echo -e "${ORANGE}[$(date "+%H:%M:%S : %D")]\n${RESET}")
time=$(echo -e "${ORANGE}[$(date "+%H:%M:%S")]\n${RESET}")

domainFile=$1

baseDir="$(pwd)"

while IFS= read -r domain; do 

    dir="results/$domain"
    cd $dir
    rm subTakeovers.txt 2> /dev/null
    rm 404.txt 2> /dev/null

    # Message main
    echo -e "\t${ORANGE}[$domain]${RESET} \t$timeDate"

    # Read subdomains and filter out 404 ones
    cat "subdomains.txt" | httpx -mc 404 2> /dev/null | sed 's/https\?:\/\///' > 404.txt

    # Checking for cname of all filtered subdomains
    file="404.txt"
    while read -r line; do
    dig "$line" | grep -a "CNAME" | grep -a "$line" >> subTakeovers.txt 
    done <$file


    # Message
    lines=$(wc -l subTakeovers.txt 2> /dev/null | awk '{print$1}')
    echo -e "\t\t|---${GREEN}[Potentially vulnerable found: $lines]${RESET} \t$time"   

    rm 404.txt

    # Go back to Project-Recon dir at last 
    cd $baseDir

done < $domainFile