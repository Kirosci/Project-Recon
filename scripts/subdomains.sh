#!/bin/bash

# ==== (INFO)
# This script enumerates subdomains for the provided targets.
# Variables imported from "consts/commonVariables.sh" (These variables are common in several scripts)
# - $SubdomainResults
# - $baseDir
# - $tempFile
# ==== (INFO)



# ===============================
# ===============================



# === (INIT)
domainFile=$1 # File containing domains to enumerate subdomains for
source consts/functions.sh # Importing file responsbile for, decorated ouput.
source consts/commonVariables.sh # Importing file responsible for, holding variables common in several scripts
assetfinder_Passive_SubdomainResults='assetfinder.txt' # Filename to save results of passive enumeration
haktrails_Passive_SubdomainResults='haktrails.txt' # Filename to save results of passive enumeration
amass_Passive_SubdomainResults='amass.txt' # Filename to save results of passive enumeration
subfinder_Passive_SubdomainResults='subfinder.txt' # Filename to save results of passive enumeration
subdominator_Passive_SubdomainResults='subdominator.txt' # Filename to save results of passive enumeration
passive_CombinedSubdomainResults='passive.CombinedSubdomainResults.txt' # Combined results of all passive tools
puredns_ResolversFile="~/.config/puredns/resolvers.txt"
alterx_Active_SubdomainResults='alterx.txt' # Filename to save results of active enumeration
dnsgen_Active_SubdomainResults='dnsgen.txt' # Filename to save results of active enumeration
altdns_Active_SubdomainResults='altdns.txt' # Filename to save results of active enumeration
active_TotalPerMuted_SubdomainResults='totalPermuted.txt' # Total permuted subdomains generated by all tools (Not yet resolved)
active_CombinedSubdomainResults='active.CombinedSubdomainResults.txt' # Combined results of all active tools (These are resolved and valid subdomains)
# This file contains combined results of passive and active results
active_and_passive_CombinedSubdomainResults='active.and.passive.CombinedSubdomainResults.txt'
# This file contains only 200 OK subdomains
liveSubdomains_SubdomainResults='liveSubdomains.txt'
# Temporary path to save tempoprary subdomains enumeration files (In real it is permanent, I mean it doesn't gets removed)
temp_SubdomainResults_Path='.tmp/subdomains' # Subdomain results path
temp_Passive_SubdomainResults_Path='.tmp/subdomains/passive' # Passive subdomain results path
temp_Active_SubdomainResults_Path='.tmp/subdomains/active' # Active subdomain results path
# === (INIT)



# ===============================
# ===============================



# --- (Setting timeouut for amass tool)

timeout=$2

# --- (Check if timeout is provided for amass tool)(END)



# ===============================
# ===============================



# --- (Check if required things like wordlist and resolvers file is there on system, Install if not)

checkWordlist() {

    # Getting wordlist name to know it's last updated date
    wordlistDate=$(ls $wordlistsDir | grep httparchive_subdomains | sed -e 's/httparchive_subdomains_//' -e 's/.txt//')
    currentDate=$(date +%Y_%m_%d)
    # Convert the dates to the format YYYYMMDD for comparison
    wordlistDate_converted=$(date -d "${wordlistDate//_/}" +%Y%m%d)
    currentDate_converted=$(date -d "${currentDate//_/}" +%Y%m%d)
    dirBackToTarget="$(dirname "$(pwd)")/$domain"

# Downloading 'resolvers.txt' if not ppresent in ~/.config/puredns/resolvers.txt

    # Define the directory and file path
    CONFIG_DIR="$HOME/.config/puredns"
    RESOLVERS_FILE="$CONFIG_DIR/resolvers.txt"
    URL="https://raw.githubusercontent.com/trickest/resolvers/main/resolvers.txt"

    # Check if the directory exists "~/.config/puredns/"
    if [ -d "$CONFIG_DIR" ]; then
        # Check if the file exists and is not empty "~/.config/puredns/resolvers.txt"
        if [ -s "$RESOLVERS_FILE" ]; then
           : # Skip If condition
        else
            curl -o "$RESOLVERS_FILE" "$URL" 2> /dev/null
        fi
    else
        mkdir -p "$CONFIG_DIR"
        curl -o "$RESOLVERS_FILE" "$URL" 2> /dev/null
    fi


# Downloading '2m-subdomains.txt' wordlist if not there
    cd $wordlistsDir
    if ! [ -f "2m-subdomains.txt" ]; then
        wget "https://wordlists-cdn.assetnote.io/data/manual/2m-subdomains.txt" 1> /dev/null
    fi
    cd $dirBackToTarget 
# Downloading in http_archive wordlist is not there
    cd $wordlistsDir
    wordlistName=$(ls | grep httparchive_subdomains_)   
    if ! [ -f $wordlistName ]; then
        wget "https://wordlists-cdn.assetnote.io/data/automated/httparchive_subdomains_$(date +%Y)_$(date +%m)_28.txt" 1> /dev/null
        rm assetnoteSubdomains.txt 2> /dev/null
        cat "httparchive_subdomains_$(date +%Y)_$(date +%m)_28.txt" "2m-subdomains.txt" | sort -u > assetnoteSubdomains.txt 
    else
        # Updating http_archive wordlist if exists
        if [ "$wordlistDate_converted" -lt "$currentDate_converted" ]; then
            if [ $(date +%d) -gt 27 ]; then
                # Updating the wordlist, If last updated date of wordlist is earlier than current date and if current date is greatter than 27
                rm httparchive_subdomains_*
                wget "https://wordlists-cdn.assetnote.io/data/automated/httparchive_subdomains_$(date +%Y)_$(date +%m)_28.txt" 1> /dev/null
                rm assetnoteSubdomains.txt 2> /dev/null
                cat "httparchive_subdomains_$(date +%Y)_$(date +%m)_28.txt" "2m-subdomains.txt" | sort -u | tee -a assetnoteSubdomains.txt
            fi
        fi
    fi
    cd $dirBackToTarget

# Generating 'assetnoteSubdomains' wordlist if not there
    cd $wordlistsDir
    if ! [ -f "assetnoteSubdomains.txt" ]; then
        cat httparchive_subdomains_* 2m-subdomains.txt | sort -u > assetnoteSubdomains.txt
    fi
    cd $dirBackToTarget

} 

# --- (Requirement check)(END)



# ===============================
# ===============================



# --- (Passive subdomain enumeration)

passiveEnumeration(){

    (
        echo "$domain" | assetfinder >> ${assetfinder_Passive_SubdomainResults}
        print_message "$GREEN" "Assetfinder: $(cat ${assetfinder_Passive_SubdomainResults} 2> /dev/null | wc -l)"
    ) &
    (
        echo "$domain" | haktrails subdomains >> ${haktrails_Passive_SubdomainResults}
        print_message "$GREEN" "Haktrails: $(cat ${haktrails_Passive_SubdomainResults} 2> /dev/null | wc -l)"
    ) &
    (
        echo "$domain" | subfinder -o ${subfinder_Passive_SubdomainResults} 2> /dev/null 1> /dev/null
        print_message "$GREEN" "Subfinder: $(cat ${subfinder_Passive_SubdomainResults} 2> /dev/null | wc -l)"
    ) &
    (
        subdominator -d "$domain" -o ${subdominator_Passive_SubdomainResults} 2> /dev/null 1> /dev/null
        print_message "$GREEN" "Subdominator: $(cat ${subdominator_Passive_SubdomainResults} 2> /dev/null | wc -l)"
    ) &

    (
        # if [ -f "${temp_Passive_SubdomainResults_Path}/${amass_Passive_SubdomainResults}" ]; then
        #     print_message "$GREEN" "Amass results are already there: $(cat "${temp_Passive_SubdomainResults_Path}/${amass_Passive_SubdomainResults}" 2> /dev/null | wc -l)"
        # else


            # amass enum -d "$domain" -o ${amass_Passive_SubdomainResults} 2> /dev/null
            # print_message "$GREEN" "Amass: $(cat ${amass_Passive_SubdomainResults} 2> /dev/null | wc -l)"



            if [[ "$2" -eq 0 ]]; then   
                print_message "$RED" "Skipping Amass"
            else   
                amass enum -d "$domain" -timeout $timeout -o ${amass_Passive_SubdomainResults} 2> /dev/null
                print_message "$GREEN" "Amass: $(cat ${amass_Passive_SubdomainResults} 2> /dev/null | wc -l)"
            fi


            # if [[ "$2" -eq 1 ]]; then   
            #     amass enum -d "$domain" -o ${amass_Passive_SubdomainResults} 2> /dev/null 1> /dev/null
            #     print_message "$GREEN" "Amass: $(cat ${amass_Passive_SubdomainResults} 2> /dev/null | wc -l)"
            # elif [[ "$2" -eq 0 ]]; then 
            #     print_message "$RED" "Skipping Amass"
            # else   
            #     # amass enum -d "$domain" -timeout $timeout -o ${amass_Passive_SubdomainResults} 2> /dev/null
            #     amass enum -d "$domain" -o ${amass_Passive_SubdomainResults} 2> /dev/null
            #     print_message "$GREEN" "Amass: $(cat ${amass_Passive_SubdomainResults} 2> /dev/null | wc -l)"
            # fi
        
        # fi
    ) &

    wait

    # Sorting and combining results
    
    cat ${assetfinder_Passive_SubdomainResults} ${subdominator_Passive_SubdomainResults} ${amass_Passive_SubdomainResults} ${haktrails_Passive_SubdomainResults} ${subfinder_Passive_SubdomainResults} 2> /dev/null | sort -u >> ${passive_CombinedSubdomainResults}

    # Appending results from previous scan if present (previous scan results are stored in temporary directory) 
    cat ${temp_Passive_SubdomainResults_Path}/${assetfinder_Passive_SubdomainResults} ${temp_Passive_SubdomainResults_Path}/${subdominator_Passive_SubdomainResults} ${temp_Passive_SubdomainResults_Path}/${amass_Passive_SubdomainResults} ${temp_Passive_SubdomainResults_Path}/${haktrails_Passive_SubdomainResults} ${temp_Passive_SubdomainResults_Path}/${subfinder_Passive_SubdomainResults} 2> /dev/null | sort -u >> ${passive_CombinedSubdomainResults}
    
    sort -u ${passive_CombinedSubdomainResults} -o ${passive_CombinedSubdomainResults} 1> /dev/null 
    
    # Filtering out false positives, writing to tempFile then renaming it to passive_CombinedSubdomainResults
    # grep -E "\\b${domain//./\\.}\\b" "${passive_CombinedSubdomainResults}" | awk '{print$1}' | sort -u >> "${tempFile}"
    cat "${passive_CombinedSubdomainResults}" | awk '{print$1}' | grep -iE "${domain}$" | sed 's/^[^a-zA-Z0-9]*//' | sed -E 's#^https?://##; s#^www*\.##' | awk '{print tolower($0)}' | sort -u >> "${tempFile}"

    mv ${tempFile} ${passive_CombinedSubdomainResults}
    
    # Combining active and passive results
    cat ${active_CombinedSubdomainResults} ${passive_CombinedSubdomainResults} 2> /dev/null | sort -u >> ${active_and_passive_CombinedSubdomainResults} 2> /dev/null

} 

# --- (Passive subdomain enumeration)(END)


# ===============================
# ===============================



# --- (Active subdomain enumeration)

activeEnumeration() {

    (
            cat "${passive_CombinedSubdomainResults}" | alterx -o ${alterx_Active_SubdomainResults} 2> /dev/null
            print_message "$GREEN" "Alterx: $(cat ${alterx_Active_SubdomainResults} 2> /dev/null | wc -l)"
    ) &
    wait

    cat ${dnsgen_Active_SubdomainResults} ${alterx_Active_SubdomainResults} ${altdns_Active_SubdomainResults} 2> /dev/null | sort -u >> ${active_TotalPerMuted_SubdomainResults}
    sort -u ${active_TotalPerMuted_SubdomainResults} -o ${active_TotalPerMuted_SubdomainResults}

# Puredns will resolve the permuted subdomains 

        cat ${active_TotalPerMuted_SubdomainResults} | dnsresolver --resolvers $(eval echo $puredns_ResolversFile) 2> /dev/null >> ${active_CombinedSubdomainResults}
        # puredns resolve "${active_TotalPerMuted_SubdomainResults}" -q >> ${active_CombinedSubdomainResults}

        cat ${active_CombinedSubdomainResults} | grep -iE "${domain}$" | sed 's/^[^a-zA-Z0-9]*//' | sed -E 's#^https?://##; s#^www*\.##' | awk '{print tolower($0)}' | sort -u -o ${active_CombinedSubdomainResults}

        print_message "$GREEN" "Active Enumeration Done] [Active Subdomains: $(cat ${active_CombinedSubdomainResults} 2> /dev/null | wc -l)"                            
        cat ${active_CombinedSubdomainResults} ${passive_CombinedSubdomainResults} 2> /dev/null | sort -u >> ${active_and_passive_CombinedSubdomainResults}
    # fi

}

# --- (Active subdomain enumeration)(END)



# ===============================
# ===============================



# --- (Take screeenshots of all found subdomains)

screenshot() {
    print_message "$GREEN" "Taking screenshots"
    nuclei -l ${SubdomainResults} -headless -t ~/nuclei-templates/headless/screenshot.yaml -c 100 2> /dev/null 1> /dev/null
}
# --- (Take screeenshots of all found subdomains)(END)



# ===============================
# ===============================



# --- (Organise mess)

organise() {
    print_message "$GREEN" "Organising found subdomains"
    # cat ${active_and_passive_CombinedSubdomainResults} 2> /dev/null | httpx -t 100 -mc 200,201,202,300,301,302,303,400,401,402,403,404 >> ${SubdomainResults} 2> /dev/null
    cp ${active_and_passive_CombinedSubdomainResults} ${SubdomainResults}
    cat ${SubdomainResults} | sed -E 's#^https?://##; s#^www*\.##' | sort -u -o ${SubdomainResults} 
    cat ${SubdomainResults} | httpx >> ${liveSubdomains_SubdomainResults} 2> /dev/null
    cat ${liveSubdomains_SubdomainResults} | sed -E 's#^https?://##; s#^www*\.##' | sort -u -o ${liveSubdomains_SubdomainResults}
    mv "${assetfinder_Passive_SubdomainResults}" "${passive_CombinedSubdomainResults}" "${subfinder_Passive_SubdomainResults}" "${subdominator_Passive_SubdomainResults}" "${amass_Passive_SubdomainResults}" "${haktrails_Passive_SubdomainResults}" "${passive_CombinedSubdomainResults}" "${temp_Passive_SubdomainResults_Path}" 2> /dev/null
    mv "${dnsgen_Active_SubdomainResults}" "${alterx_Active_SubdomainResults}" "${altdns_Active_SubdomainResults}" "${active_TotalPerMuted_SubdomainResults}" "${active_CombinedSubdomainResults}" "${temp_Active_SubdomainResults_Path}" 2> /dev/null
    mv "${active_and_passive_CombinedSubdomainResults}" "${temp_SubdomainResults_Path}" 2> /dev/null
    print_message "$GREEN" "Organising finished"
} 

# --- ((Organise mess)(END)



# ===============================
# ===============================



# --- (Kinda main function code)

for domain in $(cat "$domainFile"); do

    dir="results/$domain"
    mkdir -p "$dir"
    cp $domainFile $dir
    cd $dir 
    # Message main
    printf '\t%s[%s]%s\t%s' "$ORANGE" "$domain" "$RESET" "$timeDate"

    mkdir -p .tmp/subdomains
    mkdir -p "${temp_Passive_SubdomainResults_Path}"
    mkdir -p "${temp_Active_SubdomainResults_Path}"
    mkdir -p screenshots    

    if ! [[ "$(cat ${SubdomainResults}  2> /dev/null | wc -l)" -eq 0 ]]; then
        print_message "$GREEN" "Subdomain results are already there: $(cat ${SubdomainResults} 2> /dev/null | wc -l)"
    else
        wordlistsDir="$(dirname "$(dirname "$(pwd)")")/wordlists" 
        if [ "$3" == "passive" ]; then
            passiveEnumeration
            cat ${passive_CombinedSubdomainResults} | sort -u > ${active_and_passive_CombinedSubdomainResults}
            organise
            screenshot
        elif [ "$3" == "active" ]; then
            if [ -f "${passive_CombinedSubdomainResults}" ]; then
                checkWordlist
                activeEnumeration
                organise
                screenshot
            else
                passiveEnumeration
                checkWordlist
                activeEnumeration
                # cat ${passive_CombinedSubdomainResults} ${active_CombinedSubdomainResults} | sort -u > ${active_and_passive_CombinedSubdomainResults}
                organise
                screenshot
            fi
        elif [ "$3" == "both" ]; then
            passiveEnumeration
            checkWordlist
            activeEnumeration
            # cat ${passive_CombinedSubdomainResults} ${active_CombinedSubdomainResults} | sort -u > ${active_and_passive_CombinedSubdomainResults}
            organise
            screenshot
        else
            passiveEnumeration
            cat ${passive_CombinedSubdomainResults} | sort -u > ${active_and_passive_CombinedSubdomainResults}
            organise
            screenshot
        fi  
        # Message last
        printf '\t%s[Found: %s]%s\t%s' "$GREEN" "$(cat ${SubdomainResults} 2> /dev/null | wc -l)" "$RESET" "$timeDate"

    fi 
# Go back to Project-Recon dir at last 
    cd "$baseDir"
done

# --- (Kinda main function code)(END)
