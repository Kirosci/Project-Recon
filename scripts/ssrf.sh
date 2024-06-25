#!/bin/bash

GREEN="\e[32m"
RED="\e[31m"
ORANGE="\e[38;5;214m"
RESET="\e[0m"

timeDate=$(echo -e "${ORANGE}[$(date "+%H:%M:%S : %D")]\n${RESET}")
time=$(echo -e "${ORANGE}[$(date "+%H:%M:%S")]\n${RESET}")

domainFile=$1
link=$2

baseDir="$(pwd)"


while IFS= read -r domain; do 

    dir="results/$domain"
    cd $dir
    file="urls.txt"

    # Message main
    echo -e "\t${ORANGE}[$domain]${RESET} \t$timeDate"
    if [ -f "ssrfUrls.txt" ]; then
        echo -e "\t\t|---${GREEN}[SSRF results are already saved]${RESET} \t$time"
    else
        # For getting firdst 20 charachters of $link so we can grep for it to get proper open redirects.
        first_20="${link:0:20}"


        counter=1

        while read -r line; do
            lc=$link?no=$counter
            qs=$(echo "$line" | grep = | qsreplace -a | qsreplace $lc | awk NF |sort -u | tee -a ssrfUrls.txt)  # Use the counter in the query
            headers=$(curl -I -L "$qs" -k 2> /dev/null)
            location_header=$(echo "$headers" | grep -i "location:" 2> /dev/null)
            if [ -n "$location_header" ]; then
              url=$(echo "$location_header" | awk '{print $2}')
              echo "$qs ---> $url" >> openredirectUrls.txt
            fi

            counter=$((counter+1))
        done < "$file"

        # Filtering out proper Open Redirects
        cat openredirectUrls.txt 2> /dev/null | grep -- "---> $first_20" > openRedirects.txt 

        if ! [ $(wc -l < "openRedirects.txt") -eq 0 ]; then
            # Message
            echo -e "\t\t|---${GREEN}[Open redirects found: $(wc -l openRedirects.txt | awk '{print$1}')]${RESET} \t$time"
        else
            rm openRedirects.txt 2> /dev/null
        fi  

        rm openredirectUrls.txt 2> /dev/null
    fi    

    # Go back to Project-Recon dir at last 
    cd $baseDir
done < $domainFile