#!/bin/bash

if [[ -z "$2" ]]; then
    timeout="$2"
else
    timeout="0"
fi

GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
ORANGE=$(tput setaf 3)
RESET=$(tput sgr0) 

timeDate=$(echo -e "${ORANGE}[$(date "+%H:%M:%S : %D")]\n${RESET}")
time=$(echo -e "${ORANGE}[$(date "+%H:%M:%S")]\n${RESET}")

domainFile=$1

baseDir="$(pwd)"

# ---

# Function to calculate visible length of the message (excluding color codes)
calculate_visible_length() {
  local message=$1
  # Remove color codes
  local clean_message=$(echo -e "$message" | sed 's/\x1b\[[0-9;]*m//g')
  echo ${#clean_message}
}

# Function to print the message with aligned time
print_message() {
  local color=$1
  local message=$2
  local count=$3
  local time=$(date +"%H:%M:%S")

  if [ -n "$count" ]; then
    formatted_message=$(printf '%s[%s%d] %s' "$color" "$message" "$count" "$RESET")
  else
    formatted_message=$(printf '%s[%s] %s' "$color" "$message" "$RESET")
  fi

  visible_length=$(calculate_visible_length "$formatted_message")
  total_length=80
  spaces=$((total_length - visible_length))
  
  printf '\t\t|---%s%*s[%s]\n' "$formatted_message" "$spaces" " " "$time"
}

# ---

passiveEnumeration(){

    (
        if [ -f ".tmp/subdomains/passive/assetfinderSubdomains.txt" ]; then
            print_message "$GREEN" "Assetfinder results are already there: " "$(cat '.tmp/subdomains/passive/assetfinderSubdomains.txt' | wc -l)"
        else
            echo "$domain" | assetfinder >> assetfinderSubdomains.txt
            print_message "$GREEN" "Assetfinder:" "$(cat 'assetfinderSubdomains.txt' | wc -l)]"
        fi
    ) &
    (
        if [ -f ".tmp/subdomains/passive/haktrailsSubdomains.txt" ]; then
            print_message "$GREEN" "Haktrails results are already there: " "$(cat '.tmp/subdomains/passive/haktrailsSubdomains.txt' | wc -l)"
        else
            echo "$domain" | haktrails subdomains >> haktrailsSubdomains.txt
            print_message "$GREEN" "Haktrails:" "$(cat 'haktrailsSubdomains.txt' | wc -l)]"
        fi
    ) &
    (
        if [ -f ".tmp/subdomains/passive/subfinderSubdomains.txt" ]; then
            print_message "$GREEN" "Subfinder results are already there: " "$(cat '.tmp/subdomains/passive/subfinderSubdomains.txt' | wc -l)"
        else
            echo "$domain" | subfinder -o subfinderSubdomains.txt 2> /dev/null 1> /dev/null
            print_message "$GREEN" "Subfinder:" "$(cat 'subfinderSubdomains.txt' | wc -l)]"
        fi
    ) &
    (
        if [ -f ".tmp/subdomains/passive/subdominatorSubdomains.txt" ]; then
            print_message "$GREEN" "Subdominator results are already there: " "$(cat '.tmp/subdomains/passive/subdominatorSubdomains.txt' | wc -l)"
        else
            subdominator -d "$domain" -o subdominatorSubdomains.txt 2> /dev/null 1> /dev/null
            print_message "$GREEN" "Subdominator:" "$(cat 'subdominatorSubdomains.txt' | wc -l)]"
        fi
    ) &

    (
        if [ -f ".tmp/subdomains/passive/amassSubdomains.txt" ]; then
            print_message "$GREEN" "Amass results are already there: " "$(cat '.tmp/subdomains/passive/amassSubdomains.txt' | wc -l)"
        else
            if [[ "$2" -eq 1 ]]; then   
                amass enum -d "$domain" -o amassSubdomains.txt 2> /dev/null 1> /dev/null
                print_message "$GREEN" "Amass:" "$(cat 'amassSubdomains.txt' | wc -l)]"
            elif [[ "$2" -eq 0 ]]; then 
                print_message "$RED" "Skipping Amass"
            else    
                amass enum -d "$domain" -timeout $timeout -o amassSubdomains.txt 2> /dev/null
                print_message "$GREEN" "Amass:" "$(cat 'amassSubdomains.txt' | wc -l)]"
            fi
        fi
    ) &

    wait
    #----------------------------Sorting Assets-----------------------------------------
    
    cat assetfinderSubdomains.txt subdominatorSubdomains.txt amassSubdomains.txt haktrailsSubdomains.txt subfinderSubdomains.txt 2> /dev/null | sort -u >> combinedPassiveSubdomains.txt
    cat .tmp/subdomains/passive/assetfinderSubdomains.txt .tmp/subdomains/passive/subdominatorSubdomains.txt .tmp/subdomains/passive/amassSubdomains.txt .tmp/subdomains/passive/haktrailsSubdomains.txt .tmp/subdomains/passive/subfinderSubdomains.txt 2> /dev/null | sort -u >> combinedPassiveSubdomains.txt

    sort -u combinedPassiveSubdomains.txt -o combinedPassiveSubdomains.txt 1> /dev/null 
    # Filtering out false positives
    grep -E "\\b${domain//./\\.}\\b" "combinedPassiveSubdomains.txt" | awk '{print$1}' | sort -u >> "passiveSubdomains.txt"
    cat activeSubdomains.txt passiveSubdomains.txt 2> /dev/null | sort -u > active+passive.txt 2> /dev/null

}

# ---

checkWordlist() {

    # Getting wordlist name to know it's last updated date
    wordlistDate=$(ls $wordlistsDir | grep httparchive_subdomains | sed -e 's/httparchive_subdomains_//' -e 's/.txt//')
    currentDate=$(date +%Y_%m_%d)
    # Convert the dates to the format YYYYMMDD for comparison
    wordlistDate_converted=$(date -d "${wordlistDate//_/}" +%Y%m%d)
    currentDate_converted=$(date -d "${currentDate//_/}" +%Y%m%d)   
# Downloading '2m-subdomains.txt' wordlist if not there
    cd $wordlistsDir
    if ! [ -f "2m-subdomains.txt" ]; then
        wget "https://wordlists-cdn.assetnote.io/data/manual/2m-subdomains.txt" 1> /dev/null
    fi
    cd $dir 
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
    cd $dir
# Generating 'assetnoteSubdomains' wordlist if not there
    cd $wordlistsDir
    if ! [ -f "assetnoteSubdomains.txt" ]; then
        cat httparchive_subdomains_* 2m-subdomains.txt | sort -u > assetnoteSubdomains.txt
    fi
    cd $dir

}

# ---

activeEnumeration() {

# ---
    # (
    #     # Dnsgen will take list of subdomains (passiveSubdomains.txt) and will permute between them
    #     if [ -f ".tmp/subdomains/active/dnsgen.txt" ]; then
    #         print_message "$GREEN" "Dnsgen results are already there: " "$(cat '.tmp/subdomains/active/dnsgen.txt' | wc -l)"                            
    #     else
    #         dnsgen "passiveSubdomains.txt" -f | tee -a dnsgen.txt 1> /dev/null 2> /dev/null
    #         print_message "$GREEN" "Dnsgen:" "$(cat 'dnsgen.txt' | wc -l)]"
    #     fi
    # ) &

    # (
    # # Altdns will permute assetnote wordlist with domain name
    #     if [ -f ".tmp/subdomains/active/altdns.txt" ]; then
    #         print_message "$GREEN" "Altdns results are already there: " "$(cat '.tmp/subdomains/active/altdns.txt' | wc -l)"                            
    #     else
    #         altdns -i "$domain" -w "$wordlistsDir/assetnoteSubdomains.txt" -o altdns.txt
    #         print_message "$GREEN" "Altdns (Assetnote wordlist):" "$(cat 'altdns.txt' | wc -l)]"
    #     fi
    # ) & 

#    These abvove 2 tool generate a lot of subdomains, and puredns can't handle that, they generate nearly around 33 GB of files to resolve, That's a lot!!
# ---

    (
    # Alterx takes subdomains (passiveSubdomains.txt) and will permute between them, on behalf of specified rules
        if [ -f ".tmp/subdomains/active/alterx.txt" ]; then
            print_message "$GREEN" "Alterx results are already there: " "$(cat '.tmp/subdomains/active/alterx.txt' | wc -l)"                            
        else
            cat "passiveSubdomains.txt" | alterx -o alterx.txt 2> /dev/null
            print_message "$GREEN" "Alterx:" "$(cat 'alterx.txt' | wc -l)]"
        fi
    ) &
    wait

    cat dnsgen.txt alterx.txt altdns.txt 2> /dev/null | sort -u > totalPermuted.txt

    # Puredns will resolve the permuted subdomains 
    puredns resolve "totalPermuted.txt" -q > tee -a activeSubdomains.txt
    print_message "$GREEN" "Active Enumeration Done] [Active Subdomains: " "$(cat 'activeSubdomains.txt' | wc -l)"                            
    cat activeSubdomains.txt passiveSubdomains.txt | sort -u > active+passive.txt

}
# ---

organise() {
    cat active+passive.txt | httpx -t 100 -mc 200,201,202,300,301,302,303,400,401,402,403,404 -o subdomains.txt 2> /dev/null 1> /dev/null
    cat subdomains.txt | httpx -o liveSubdomains.txt 2> /dev/null 1> /dev/null
    mv "assetfinderSubdomains.txt" "combinedPassiveSubdomains.txt" "subfinderSubdomains.txt" "subdominatorSubdomains.txt" "amassSubdomains.txt" "haktrailsSubdomains.txt" "passiveSubdomains.txt " ".tmp/subdomains/passive" 2> /dev/null
    mv "dnsgen.txt" "alterx.txt" "altdns.txt" "totalPermuted.txt" "activeSubdomains.txt" ".tmp/subdomains/active" 2> /dev/null
    mv "active+passive.txt" ".tmp/subdomains/" 2> /dev/null
}

# ---

screenshot() {
    nuclei -l subdomains.txt -headless -t ~/nuclei-templates/headless/screenshot.yaml -c 100 2> /dev/null 1> /dev/null
}

# ---

for domain in $(cat "$domainFile"); do

    dir="results/$domain"
    mkdir -p "$dir" 
    cd $dir 
    # Message main
    printf '\t%s[%s]%s\t%s' "$ORANGE" "$domain" "$RESET" "$timeDate"

    mkdir -p .tmp/subdomains
    mkdir -p .tmp/subdomains/passive
    mkdir -p .tmp/subdomains/active
    mkdir -p screenshots    

    wordlistsDir="$(pwd)/wordlists" 
    if [ "$3" == "passive" ]; then
        passiveEnumeration
        cat passiveSubdomains.txt | sort -u > active+passive.txt
        screenshot
        organise
    elif [ "$3" == "active" ]; then
        if [ -f "passiveSubdomains.txt" ]; then
            checkWordlist
            activeEnumeration
            organise
            screenshot
        else
            passiveEnumeration
            checkWordlist
            activeEnumeration
            cat passiveSubdomains.txt activeSubdomains.txt | sort -u > active+passive.txt
            organise
            screenshot
        fi
    elif [ "$3" == "both" ]; then
        passiveEnumeration
        checkWordlist
        activeEnumeration
        cat passiveSubdomains.txt activeSubdomains.txt | sort -u > active+passive.txt
        organise
        screenshot
    else
        passiveEnumeration
        cat passiveSubdomains.txt | sort -u > active+passive.txt
        organise
        screenshot
    fi  
    # Message last
    printf '\t%s[%s]%s\t%s' "$ORANGE" "$domain" "$RESET" "$timeDate"
    printf '\t%s[Found: %s]%s\t%s' "$GREEN" "$(cat subdomains.txt | wc -l)" "$RESET" "$timeDate"

# Go back to Project-Recon dir at last 
    cd "$baseDir"
done
