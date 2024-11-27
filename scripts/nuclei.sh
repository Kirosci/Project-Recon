#!/bin/bash

# ==== (INFO)
# This script fuzzes all subdomains of the provided targets.
# Variables imported from "consts/commonVariables.sh" (These variables are common in several scripts)
# - $SubdomainResults
# - $baseDir
# ==== (INFO)(END)

# ---- (INIT)
domainFile=$1 # File containing domains to enumerate subdomains for
source consts/functions.sh # Importing file responsbile for, decorated ouput.
source consts/commonVariables.sh # Importing file responsible for, holding variables common in several scripts
nucleiResults='nuclei.txt' # File name for saving nuclei results
# ---- (INIT)



# ===============================
# ===============================



# --- (Sort of main function)

while IFS= read -r domain; do 

    dir="results/$domain"
    cd $dir
    # if [ -f "${nucleiResults}" ]; then
    #     # Message
    #     print_message "$GREEN" "Nuclei results are already there: "$(cat ${nucleiResults} 2> /dev/null | wc -l)""
    # else
        # Message main
        printf '\t%s[%s]%s\t%s' "$ORANGE" "$domain" "$RESET" "$timeDate"

    # Calling Nuclei
        nuclei -l ${SubdomainResults} -t ~/nuclei-templates/ -c 50 -fr -rl 20 -timeout 20 -o ${nucleiResults}
        # Message
        print_message "$ORANGE" "Finished; lines in ${nucleiResults}: "$(cat ${nucleiResults} 2> /dev/null | wc -l)""

    # fi

    # Go back to Project-Recon dir at last 
    cd $baseDir
done < $domainFile