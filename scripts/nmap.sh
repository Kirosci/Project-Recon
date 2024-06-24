#!/bin/bash

domainFile=$1

GREEN="\e[32m"
RED="\e[31m"
RESET="${RESET}"

getASN() {
# Find Ip Rnages from ASN
while IFS= read -r domain; do 

    dir="results/$domain"
    cd $dir

    python3 $baseDir/scripts/getAsn.py $domain

    sort -u asn.txt -o asn.txt 2> /dev/null

    while IFS= read -r ASN; do
        whois -h whois.radb.net -- '-i origin' "$ASN" | grep -Eo "([0-9.]+){4}/[0-9]+" | uniq  | tee -a ipRanges.txt 1> /dev/null
    done < "asn.txt"

    sort -u ipRanges.txt -o ipRanges.txt 2> /dev/null


    # Go back to Project-Recon dir at last 
    cd $baseDir

done < $domainFile

}



if ! [ $(wc -l < "ipRanges.txt") -eq 0 ]; then

    echo "[+] Running Nmap Scan"
    python3 $baseDir/scripts/nmap.py $domainFile

fi

