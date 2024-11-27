#!/bin/bash

# ==== (INFO)
# This script fuzzes all subdomains of the provided targets.
# Variables imported from "consts/commonVariables.sh" (These variables are common in several scripts)
# - $UrlResults
# - $baseDir
# - $jsUrls
# ==== (INFO)(END)

# === (INIT)
domainFile=$1 # File containing domains to enumerate subdomains for
source consts/functions.sh # Importing file responsbile for, decorated ouput.
source consts/commonVariables.sh # Importing file responsible for, holding variables common in several scripts
subjs_JsResults='subjs.txt' # Filename to save results
jsFetched_Directory='js/fetched' # Js Fetched directory name
fetched_Directory='fetched' # Fetched directory name
jsNuclei_Results='js/jsNuclei.txt' # Js Nuclei results
# === (INIT)(END)



# ===============================
# ===============================



# --- (Sort of Main function)

while IFS= read -r domain; do 

    dir="results/$domain"
    cd $dir
    mkdir -p js
  
    printf '\t%s[%s]%s\t%s' "$ORANGE" "$domain" "$RESET" "$timeDate" # Message main
    print_message "$GREEN" "Gathering JS Urls from subjs tool" # Message

# subjs tool
    subjs -i ${UrlResults} > ${subjs_JsResults}
    cat ${subjs_JsResults} | grep -F .js | cut -d "?" -f 1 | sort -u >>  ${jsUrls}
    sort -u ${jsUrls} -o ${jsUrls}

# Downloading JS files, from collected endpoints
    
    print_message "$GREEN" "Saving JavaScript files locally" # Message

# Calling bash file to download js files
    fetcher -f ${jsUrls} -t 120 -x 15 1> /dev/null
    # bash "$baseDir/scripts/jsRecon/downloadJS.sh" -f ${jsUrls} -t 10 -r 2 -x 12
    mv ${fetched_Directory} ${jsFetched_Directory}
    
    print_message "$GREEN" "JS file collected: $(ls ${jsFetched_Directory} | wc -l)" # Message
    print_message "$GREEN" "Extracting juicy stuff" # Message

    (
        bash "$baseDir/scripts/jsRecon/main.sh" -dir="${jsFetched_Directory}" 1> /dev/null
    ) &
    
    (
        echo "${jsFetched_Directory}" | nuclei -l ${jsUrls} -c 100 -retries 2 -t ~/nuclei-templates/exposures/ -o ${jsNuclei_Results} 1> /dev/null 2> /dev/null
    ) &
    wait

    # Go back to Project-Recon dir at last 
    cd $baseDir

done < $domainFile