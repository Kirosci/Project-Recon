#!/bin/bash

# ==== (INFO)

# This script gathers urls for all subdomains of the provided targets.

# Variables imported from "consts/commonVariables.sh" (These variables are common in several scripts)
# - $UrlResults
# - $baseDir
# - $jsUrls
# ==== (INFO)(END)



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



# --- (INIT)

# File containing domains to enumerate subdomains for
domainFile=$1

# Importing file responsbile for, decorated ouput.
source consts/functions.sh
# Importing file responsible for, holding variables common in several scripts
source consts/commonVariables.sh


# Filenames to save results of url enumeration

    # Passive enumeration
        waybackurls_Passive_UrlResults='waybackurls.txt'
        gau_Passive_UrlResults='gau.txt'
        waymore_Passive_UrlResults='waymore.txt'
    
    # Active enumeration
        katana_Active_UrlResults='katana.txt'
        hakrawler_Active_UrlResults='hakrawler.txt'

# Temporary path to save tempoprary subdomains enumeration files (In real it is permanent, I mean it doesn't gets removed)

    temp_UrlResults_Path='.tmp/urls'

# --- (INIT)(END)



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



# --- (Passive URL gathering)

passive() {
    (
        # if [ -f "${temp_UrlResults_Path}/${waybackurls_Passive_UrlResults}" ]; then
        #     print_message "$GREEN" "Waybackurls results are already there: $(cat "${temp_UrlResults_Path}/${waybackurls_Passive_UrlResults}" 2> /dev/null | wc -l)"
        # else
            # cp ${SubdomainResults} temp_subdomains_wayback.txt && 
            cat ${SubdomainResults} | waybackurls > ${waybackurls_Passive_UrlResults} 2> /dev/null

            print_message "$GREEN" "Waybackurls: $(cat "${waybackurls_Passive_UrlResults}" 2> /dev/null | wc -l)"
        # fi
    ) &
    (
        # if [ -f "${temp_UrlResults_Path}/${gau_Passive_UrlResults}" ]; then
        #     print_message "$GREEN" "Gau results are already there: $(cat "${temp_UrlResults_Path}/${gau_Passive_UrlResults}" 2> /dev/null | wc -l)"
        # else
            # cp ${SubdomainResults} temp_subdomains_gau.txt && 
            cat ${SubdomainResults} | gau > ${gau_Passive_UrlResults} 2> /dev/null

            print_message "$GREEN" "Gau: $(cat "${gau_Passive_UrlResults}" 2> /dev/null | wc -l)"
        # fi
    ) &
    (
        # if [ -f "${temp_UrlResults_Path}/${waymore_Passive_UrlResults}" ]; then
        #     print_message "$GREEN" "Waymore results are already there: $(cat "${temp_UrlResults_Path}/${waymore_Passive_UrlResults}" 2> /dev/null | wc -l)"
        # else
            # cp ${SubdomainResults} temp_subdomains_waymore.txt && 
            cat ${SubdomainResults} | sed 's/^/https:\/\//' > ${tempFile}
            waymore -n -xwm -urlr 0 -r 2 -i ${tempFile} -mode U -oU ${waymore_Passive_UrlResults} 2> /dev/null 1> /dev/null
            rm ${tempFile} 2> /dev/null
            print_message "$GREEN" "Waymore: $(cat "${waymore_Passive_UrlResults}" 2> /dev/null | wc -l)"
        # fi
    ) &
    
    wait

    # rm temp_subdomains_wayback.txt temp_subdomains_gau.txt temp_subdomains_waymore.txt 2> /dev/null
}

# --- (Passive URL gathering)(END)



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



# --- (Active URL gathering)

active() {
    (
        # if [ -f "${temp_UrlResults_Path}/${katana_Active_UrlResults}" ]; then
        #     print_message "$GREEN" "Katana results are already there: $(cat "${temp_UrlResults_Path}/${katana_Active_UrlResults}" 2> /dev/null | wc -l)"
        # else
            katana -u ${SubdomainResults} -o ${katana_Active_UrlResults} -silent -hl -nc -d 5 -aff -retry 2 -iqp -c 20 -p 20 -xhr -jc -kf -ef css,jpg,jpeg,png,svg,img,gif,mp4,flv,ogv,webm,webp,mov,mp3,m4a,m4p,scss,tif,tiff,ttf,otf,woff,woff2,bmp,ico,eot,htc,rtf,swf,image 1> /dev/null

            print_message "$GREEN" "Katana: $(cat "${katana_Active_UrlResults}" 2> /dev/null | wc -l)"
        # fi
    ) &

    (
        # if [ -f "${temp_UrlResults_Path}/${hakrawler_Active_UrlResults}" ]; then
        #     print_message "$GREEN" "Hakrawler results are already there: $(cat "${temp_UrlResults_Path}/${hakrawler_Active_UrlResults}" 2> /dev/null | wc -l)"
        # else
            cat ${SubdomainResults} | hakrawler -d 5 -insecure -subs -t 40 > ${hakrawler_Active_UrlResults} 2> /dev/null

            print_message "$GREEN" "Hakrawler: $(cat "${hakrawler_Active_UrlResults}" 2> /dev/null | wc -l)"
        # fi
    ) & 
    
    wait

}

# --- (Active URL gathering)(END)



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



# --- (Funtion to organise mess)

organise(){

    # Sorting and combining results
    print_message "$GREEN" "Organising collected urls"
    cat ${waybackurls_Passive_UrlResults} ${gau_Passive_UrlResults} ${waymore_Passive_UrlResults} ${katana_Active_UrlResults} ${hakrawler_Active_UrlResults} 2> /dev/null | sort -u >> ${UrlResults}

    # Appending results from previous scan if present (previous scan results are stored in temporary directory) 
    cat ${temp_UrlResults_Path}/${waybackurls_Passive_UrlResults} ${temp_UrlResults_Path}/${gau_Passive_UrlResults} ${temp_UrlResults_Path}/${waymore_Passive_UrlResults} ${temp_UrlResults_Path}/${katana_Active_UrlResults} ${temp_UrlResults_Path}/${hakrawler_Active_UrlResults} 2> /dev/null | sort -u >> ${UrlResults}

    # Sorting results again
    sort -u ${UrlResults} -o ${UrlResults} 1> /dev/null
    
    # Separating Js and json urls
    cat ${UrlResults} | grep -F .js | cut -d "?" -f 1 | sort -u >> ${jsUrls} 1> /dev/null

    # Moving unnecessary to temporary directory
    mv ${waybackurls_Passive_UrlResults} ${gau_Passive_UrlResults} ${waymore_Passive_UrlResults} ${katana_Active_UrlResults} ${hakrawler_Active_UrlResults} ${tempFile} ${temp_UrlResults_Path} 2> /dev/null
    print_message "$GREEN" "Organising finished"
}

# --- (Funtion to organise mess)(END)



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



# --- (Kinda main function code)

# Used for-loop specifically, don't switch to while-loop, it was having some problems with waymore tool
for domain in $(cat "$domainFile"); do
    dir="results/$domain"
    cd "$dir"
    mkdir -p ${temp_UrlResults_Path}


    # Message main
    printf '\t%s[%s]%s\t%s' "$ORANGE" "$domain" "$RESET" "$timeDate"

    if ! [[ "$(cat ${UrlResults} 2> /dev/null |wc -l)" -eq 0 ]]; then
        print_message "$GREEN" "URL results are already there: $(cat "${UrlResults}" 2> /dev/null | wc -l)"
    else
        if [ "$2" == "passive" ]; then
            passive
            organise
        elif [ "$2" == "active" ]; then
            active
            organise
        elif [ "$2" == "both" ]; then
            passive
            active
            organise
        else
            passive
            organise
        fi
    fi
    # Message last
    printf '\t%s[Found: %s]%s\t%s' "$GREEN" "$(cat ${UrlResults} 2> /dev/null | wc -l)" "$RESET" "$timeDate"
    # Go back to base directory at last 
    cd "$baseDir"
done

# --- (Kinda main function code)(END)