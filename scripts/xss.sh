#!/bin/bash

# ==== (INFO)
# This script fuzzes all subdomains of the provided targets.
# Variables imported from "consts/commonVariables.sh" (These variables are common in several scripts)
# - $UrlResults
# ==== (INFO)(END)

# --- (INIT)
domainFile=$1 # File containing domains to enumerate subdomains for
source consts/functions.sh # Importing file responsbile for, decorated ouput.
source consts/commonVariables.sh # Importing file responsible for, holding variables common in several scripts
xssResults='xss.txt' # Filename name for saving xss results
# --- (INIT)



# ===============================
# ===============================



# --- (Sort of main function)

while IFS= read -r domain; do 

    dir="results/$domain"
    cd $dir
    
    # Message main
    printf '\t%s[%s]%s\t%s' "$ORANGE" "$domain" "$RESET" "$timeDate"

    # if [ -f "${xssResults}" ]; then
    #     print_message "$GREEN" "XSS results are already there: "$(cat ${xssResults} 2> /dev/null | wc -l)""
    # else
        cat "${UrlResults}" | grep = | kxss | grep '>\|<\|"' > ${xssResults}

        # Message
        if ! [ $(wc -l < "${xssResults}") -eq 0 ]; then
            print_message "$GREEN" "RXSS found: "$(cat ${xssResults} 2> /dev/null | wc -l)""
        else
            rm ${xssResults} 2> /dev/null
        fi
    # fi

    # Go back to Project-Recon dir at last 
    cd $baseDir
done < $domainFile

# --- (Main function)(END)