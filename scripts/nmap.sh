#!/bin/bash

GREEN="\e[32m"
RED="\e[31m"
ORANGE="\e[38;5;214m"
RESET="\e[0m"

timeDate=$(echo -e "${ORANGE}[$(date "+%H:%M:%S : %D")]\n${RESET}")
time=$(echo -e "${ORANGE}[$(date "+%H:%M:%S")]\n${RESET}")

domainFile=$1

getASN() {
# Find Ip Rnages from ASN
while IFS= read -r domain; do 

    dir="results/$domain"
    cd $dir

    # Message main
    echo -e "\t${ORANGE}[$domain]${RESET} \t$timeDate"

# Getting ASN
    # Message
    echo -e "\t\t|---${GREEN}[Gathering ASN]${RESET} \t$time"   

    # Calling python file responsible of rgetting ASN
    python3 $baseDir/scripts/getAsn.py $domain 1> /dev/null
    sort -u asn.txt -o asn.txt 2> /dev/null 1> /dev/null

    # Message
    lines=$(cat asn.txt | wc -l)
    echo -e "\t\t|---${GREEN}[ASN found: $lines]${RESET} \t$time"


# Extracting IP Ranges, if any ASN found
    if ! [ $(wc -l < "asn.txt") -eq 0 ]; then

        # Message
        echo -e "\t\t|---${GREEN}[Extracting IP ranges for $domain]${RESET} \t$time"

        while IFS= read -r ASN; do
            whois -h whois.radb.net -- '-i origin' "$ASN" | grep -Eo "([0-9.]+){4}/[0-9]+" | uniq  | tee -a ipRanges.txt 1> /dev/null
        done < "asn.txt"
        sort -u ipRanges.txt -o ipRanges.txt 2> /dev/null 1> /dev/null

        # Message
        lines=$(cat ipRanges.txt | wc -l)
        echo -e "\t\t|---${GREEN}[IP ranges found: $lines]${RESET} \t$time"

    fi
    

    # Go back to Project-Recon dir at last 
    cd $baseDir

done < $domainFile

}


# Scan the Ip ranges
scanRange() {

if ! [ $(wc -l < "ipRanges.txt") -eq 0 ]; then

    # Message
    echo -e "\t\t|---${GREEN}[Nmap scan started]${RESET} \t$timeDate"

# Calling NMAP
    python3 $baseDir/scripts/nmap.py $domainFile 1> /dev/null

fi

}


# Call of Nmap ;)
getASN
scanRange

