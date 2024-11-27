#!/bin/bash

# ==== (INFO)
# This script fuzzes all subdomains of the provided targets.
# Variables imported from "consts/commonVariables.sh" (These variables are common in several scripts)
# - $tempFile
# - $SubdomainResults
# ==== (INFO)(END)

# --- (INIT)
domainFile=$1 # File containing domains to enumerate subdomains for
source consts/functions.sh # Importing file responsbile for, decorated ouput.
source consts/commonVariables.sh # Importing file responsible for, holding variables common in several scripts
subTakeoversResults='subTakeovers.txt' # Filename name for saving takeover results
# --- (INIT)



# ===============================
# ===============================



# --- (Sort of main function)

while IFS= read -r domain; do
    
    dir="results/$domain"
    cd $dir
    rm ${subTakeoversResults} 2> /dev/null
    rm ${tempFile} 2> /dev/null
    
    # Message main
    printf '\t%s[%s]%s\t%s' "$ORANGE" "$domain" "$RESET" "$timeDate"
    
    # Read subdomains and filter out 404 ones
    cat "${SubdomainResults}" | httpx -mc 404 2> /dev/null | sed 's/https\?:\/\///' > ${tempFile}
    
    # Checking for cname of all filtered subdomains
    file="${tempFile}"
    while read -r line; do
        dig "$line" | grep -a "CNAME" | grep -a "$line" >> ${subTakeoversResults}
    done <$file
    
    
    # Message
    print_message "$GREEN" "Subdomain Takeover found: "$(cat ${subTakeoversResults} 2> /dev/null | wc -l)""
    
    rm ${tempFile}
    
    # Go back to Project-Recon dir at last
    cd $baseDir
    
done < $domainFile

# --- (Main function)(END)