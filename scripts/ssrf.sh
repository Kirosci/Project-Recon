
#!/bin/bash

# ==== (INFO)
# This script fuzzes all subdomains of the provided targets.
# Variables imported from "consts/commonVariables.sh" (These variables are common in several scripts)
# - $tempFile
# - $UrlResults
# ==== (INFO)(END)

# --- (INIT)
link=$2 # Get attacker server url
domainFile=$1 # File containing domains to enumerate subdomains for
source consts/functions.sh # Importing file responsbile for, decorated ouput.
source consts/commonVariables.sh # Importing file responsible for, holding variables common in several scripts
ssrfResults='ssrfUrls.txt' # Filename name for saving ssrf results
openredirectResults='openRedirects.txt' # Filename name for saving operedirect results
# --- (INIT)



# ===============================
# ===============================



# --- (Sort of main function)

while IFS= read -r domain; do 

    dir="results/$domain"
    cd $dir

    # Message main
    printf '\t%s[%s]%s\t%s' "$ORANGE" "$domain" "$RESET" "$timeDate"

    # if [ -f "${ssrfResults}" ]; then
    #     # Message
    #     print_message "$GREEN" "SSRF results are already saved"
    # else
        # For getting firdst 20 charachters of $link so we can grep for it to get proper open redirects.
        first_20="${link:0:20}"


        counter=1

        while read -r line; do
            lc=$link?no=$counter
            qs=$(echo "$line" | grep = | qsreplace -a | qsreplace $lc | awk NF |sort -u | tee -a ${ssrfResults})  # Use the counter in the query
            headers=$(curl -I -L "$qs" -k 2> /dev/null)
            location_header=$(echo "$headers" | grep -i "location:" 2> /dev/null)
            if [ -n "$location_header" ]; then
              url=$(echo "$location_header" | awk '{print $2}')
              echo "$qs ---> $url" >> ${tempFile}
            fi

            counter=$((counter+1))
        done < "${UrlResults}"

        # Filtering out proper Open Redirects
        cat ${tempFile} 2> /dev/null | grep -- "---> $first_20" > ${openredirectResults} 

        if ! [ $(wc -l < "${openredirectResults}") -eq 0 ]; then
            # Message
            print_message "$GREEN" "Open redirects found: "$(cat ${openredirectResults} 2> /dev/null | wc -l)""
        else
            rm ${openredirectResults} 2> /dev/null
        fi  

        rm ${tempFile} 2> /dev/null
    # fi    

    # Go back to Project-Recon dir at last 
    cd $baseDir
done < $domainFile

# --- (Main function)(END)