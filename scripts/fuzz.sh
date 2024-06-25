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

    # Message main
    echo -e "\t${ORANGE}[$domain]${RESET} \t$timeDate"

    # Message
    echo -e "\t\t|---${GREEN}[Fuzzing started]${RESET} \t$time"

    (
    dirsearch -l subdomains.txt  -w wordlists/mixedMedium.txt -t 10 -i 200 -o fuzz_mixedBig.txt
    ) &

    (
    dirsearch -l subdomains.txt  -w wordlists/dirSmall.txt -t 10 -i 200 -o fuzz_dirSmall.txt
    ) &

    wait

    cat fuzz_mixedBig.txt fuzz_dirSmall.txt | sort -u | fuzz.txt


    mkdir fuzz
    mv fuzz_mixedBig.txt fuzz/
    mv fuzz_dirSmall.txt fuzz/

    # Message
    echo -e "\t\t|---${GREEN}[Fuzzing finished]${RESET} \t$time"

    # Message last
    echo -e "\t${ORANGE}[fuzz_mixedBig.txt: $(cat fuzz/fuzz_mixedBig.txt | wc -l) | fuzz_dirSmall.txt: $(cat fuzz/fuzz_dirSmall.txt | wc -l)]${RESET} \t$timeDate"
    
    # Go back to Project-Recon dir at last 
    cd $baseDir

done < $domainFile