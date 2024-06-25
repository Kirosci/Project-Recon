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

# Checking if jsUrls doesn't exists
    if ! [ -f "jsUrls.txt" ]; then
    

        # Message
        echo -e "\t\t|---${GREEN}[jsUrls.txt not found, creating...]${RESET} \t$time"
        cat urls.txt | grep -F .js | cut -d "?" -f 1 | sort -u | tee tmpJsUrls.txt 2> /dev/null 1> /dev/null 

        # Separating js urls 
        cat tmpJsUrls.txt | httpx -t 100 -mc 200 > jsUrls.txt 2> /dev/null

        # Message
        echo -e "\t\t|---${GREEN}[Created jsUrls.txt, Lines: $(cat jsUrls.txt | wc -l)]${RESET} \t$time"

        mv tmpJsUrls.txt .tmp/urls 2> /dev/null

    fi


# Downloading JS files, from collected endpoints

    # Message
    echo -e "\t\t|---${GREEN}[Saving JavaScript files locally]${RESET} \t$time"

# Calling bash file to download js files
    bash "$baseDir/scripts/jsRecon/downloadJS.sh" -f jsUrls.txt -t 10 -r 2 -x 12
    wait

    # Message
    echo -e "\t\t|---${GREEN}[JS file collected: $(ls js/jsSourceFiles | wc -l)]${RESET} \t$time"

    sleep 10

    # Message
    echo -e "\t\t|---${GREEN}[Extracting juicy stuff]${RESET} \t$time"
    (
        bash "$baseDir/scripts/jsRecon/main.sh" -dir=js
    ) &
    
    (
        echo "js/jsSourceFiles" | nuclei -l jsUrls.txt -c 100 -retries 2 -t ~/nuclei-templates/exposures/ -o js/jsNuclei.txt
    ) &
    wait


    # Go back to Project-Recon dir at last 
    cd $baseDir

done < $domainFile