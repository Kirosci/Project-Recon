#!/bin/bash

# ==== (INFO)
# This script fuzzes all subdomains of the provided targets.
# Variables imported from "consts/commonVariables.sh" (These variables are common in several scripts)
# - $SubdomainResults
# - $baseDir
# ==== (INFO)(END)

# --- (INIT)
domainFile=$1 # File containing domains to enumerate subdomains for
source consts/functions.sh # Importing file responsbile for, decorated ouput.
source consts/commonVariables.sh # Importing file responsible for, holding variables common in several scripts
FuzzResults='fuzz.txt' # Filename to save combined fuzz results
fuzz_Directory_Results='fuzz' # Directory name for saving results
wordlist_MixedMedium_Path='../../wordlists/mixedMedium.txt' # Wordlist path for fuzzing
wordlist_DirSmall_Path='../../wordlists/dirSmall.txt' # Wordlist path for fuzzing
fuzz_MixedMedium_Results='fuzz_mixedMedium.txt' # Filename for saving fuzzing results
fuzz_DirSmall_Results='fuzz_dirSmall.txt' # Filename for saving fuzzing results
# --- (INIT)



# ===============================
# ===============================



# --- (Sort of Main function)

while IFS= read -r domain; do 

    dir="results/$domain"
    cd $dir
    
    printf '\t%s[%s]%s\t%s' "$ORANGE" "$domain" "$RESET" "$timeDate" # Message main

    # if [ -f "${fuzz_Directory_Results}/${fuzz_MixedMedium_Results}" ] && [ -f "${fuzz_Directory_Results}/${fuzz_DirSmall_Results}" ]; then
    #     print_message "$GREEN" "Fuzz results are already there: ${fuzz_MixedMedium_Results}=$(cat ${fuzz_Directory_Results}/${fuzz_MixedMedium_Results} 2> /dev/null | wc -l) | ${fuzz_DirSmall_Results}=$(cat ${fuzz_Directory_Results}/${fuzz_DirSmall_Results} 2> /dev/null | wc -l)"
    # else

        (
        dirsearch -l ${SubdomainResults}  -w ${wordlist_MixedMedium_Path} -t 10 -i 200 -o "${fuzz_MixedMedium_Results}" 2> /dev/null
        ) &

        (
        dirsearch -l ${SubdomainResults}  -w ${wordlist_MixedMedium_Path} -t 10 -i 200 -o ${fuzz_DirSmall_Results} 2> /dev/null
        ) &

        wait

      # Combining fuzzed results
        cat ${fuzz_MixedMedium_Results} ${fuzz_DirSmall_Results} 2> /dev/null | sort -u | tee -a ${FuzzResults}

      # Make dir and move results into
        mkdir -p ${fuzz_Directory_Results}
        mv ${fuzz_MixedMedium_Results} ${fuzz_Directory_Results}
        mv ${fuzz_DirSmall_Results} ${fuzz_Directory_Results}

        # Message
        print_message "$GREEN" "${fuzz_MixedMedium_Results}: $(cat ${fuzz_Directory_Results}/${fuzz_MixedMedium_Results} 2> /dev/null | wc -l) | ${fuzz_DirSmall_Results}: $(cat ${fuzz_Directory_Results}/${fuzz_DirSmall_Results} 2> /dev/null | wc -l)"

    # fi
    
    # Go back to Project-Recon dir at last 
    cd $baseDir
done < $domainFile

# --- (Main function)(END)