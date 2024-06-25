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

    rm nuclei.txt 2> /dev/null

    # Message main
    echo -e "\t${ORANGE}[$domain]${RESET} \t$timeDate"

# Calling Nuclei
    nuclei -l subdomains.txt -c 50 -fr -rl 20 -timeout 20 -o nuclei.txt -t cent-nuclei-templates

    # Message
    echo -e "\t\t|---${GREEN}[Finished, lines in nuclei.txt: $(wc -l nuclei.txt | awk '{print$1}')]${RESET} \t$time"

    # Go back to Project-Recon dir at last 
    cd $baseDir

done < $domainFile