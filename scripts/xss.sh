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

    if [ -f "xss.txt" ]; then
        echo -e "\t\t|---${GREEN}[XSS results are already there: $(cat 'xss.txt' | wc -l)]${RESET} \t$time"
    else
        cat "urls.txt" | grep = | kxss | grep '>\|<\|"' > xss.txt

        # Message
        if ! [ $(wc -l < "xss.txt") -eq 0 ]; then
            lines=$(wc -l xss.txt 2> /dev/null | awk '{print$1}')
            echo -e "\t\t|---${GREEN}[Potentially vulnerable found: $lines]${RESET} \t$time"   
        else
            rm xss.txt 2> /dev/null
        fi
    fi

    # Go back to Project-Recon dir at last 
    cd $baseDir
done < $domainFile
