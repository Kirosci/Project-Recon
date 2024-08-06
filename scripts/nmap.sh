#!/bin/bash

# ==== (INFO)
# This script fuzzes all subdomains of the provided targets.
# Variables imported from "consts/commonVariables.sh" (These variables are common in several scripts)
# - $tempFile
# - $baseDir
# ==== (INFO)(END)

# ---- (INIT)
domainFile=$1 # File containing domains to enumerate subdomains for
source consts/functions.sh # Importing file responsbile for, decorated ouput.
source consts/commonVariables.sh # Importing file responsible for, holding variables common in several scripts
ipRanges_file_path='ipRanges.txt' # Filename to save found IP ranges
subdomainIps_file_path='subdomainIps.txt' # Filename to save found IP ranges
subdomainActivePassive_file_path='.tmp/subdomains/active+passive.txt' # Filename to save found IP ranges
network_Directory_Results='network' # Directory name for saving other stuff
# ---- (INIT)



# ===============================
# ===============================



# --- (Get ASN numbers from bgp.he.net)

getASN() {
# Find Ip Rnages from ASN
while IFS= read -r domain; do 

    dir="results/$domain"
    cd $dir

  # Removing previous ${network_Directory_Results} directory
    rm -rf ${network_Directory_Results} 2> /dev/null

    # Message main
    printf '\t%s[%s]%s\t%s' "$ORANGE" "$domain" "$RESET" "$timeDate"

# Getting ASN
    # Message
    print_message "$GREEN" "Gathering ASN"

    # Calling python file responsible of rgetting ASN
    python3 "$baseDir/scripts/getAsn.py" $domain 1> /dev/null
    sort -u asn.txt -o asn.txt 2> /dev/null 1> /dev/null

    # Message
    print_message "$GREEN" "ASN found "$(cat 'asn.txt' 2> /dev/null | wc -l)""

# Extracting IP Ranges, if any ASN found
    if ! [[ $(wc -l < "asn.txt") -eq 0 ]]; then

        # Message
        print_message "$GREEN" "Extracting IP ranges for $domain"

        while IFS= read -r ASN; do
            whois -h whois.radb.net -- '-i origin' "$ASN" | grep -Eo "([0-9.]+){4}/[0-9]+" | uniq  | tee -a ${ipRanges_file_path} 1> /dev/null
        done < "asn.txt"
        sort -u ${ipRanges_file_path} -o ${ipRanges_file_path} 2> /dev/null 1> /dev/null

        # Message
        print_message "$GREEN" "IP ranges found "$(cat ${ipRanges_file_path} 2> /dev/null | wc -l)""

    fi

# Getting IPs of found subdomains
    # Message
    print_message "$GREEN" "Extracting IPs from subdomains of $domain"
    while IFS= read -r subdomain; do
        dig +short "$subdomain" | tee -a ${subdomainIps_file_path} > /dev/null

    done < "${subdomainActivePassive_file_path}"

    # Use grep with the regex to check if the line contains an IPv4 address (Removing subdomains, as sometimes `dig` command gives subdomains too. for example: status.withsecure.com)
    while IFS= read -r line; do
      if echo "$line" | grep -E '^([0-9]{1,3}\.){3,4}[0-9]{1,3}$' > /dev/null; then
          # If the line is IP then, append it to the ${subdomainIps_file_path} file
          echo "$line" >> "${tempFile}"
      fi
    done < "${subdomainIps_file_path}"
    
    sort -u ${tempFile} -o ${subdomainIps_file_path}

    rm ${tempFile}

    # Message
    print_message "$GREEN" "IPs found "$(cat ${subdomainIps_file_path} 2> /dev/null | wc -l)""


# Scan through nmap
    if ! [[ $(cat "${ipRanges_file_path}" 2> /dev/null | wc -l 2> /dev/null) -eq 0 ]] || ! [[ $(cat "${subdomainIps_file_path}" 2> /dev/null | wc -l 2> /dev/null) -eq 0 ]]; then

      # Message
      print_message "$GREEN" "Nmap scan started"

      mkdir -p ${network_Directory_Results}
      mv ${ipRanges_file_path} ${subdomainIps_file_path} asn.txt ${network_Directory_Results} 2> /dev/null

    # Calling NMAP
      python3 "$baseDir/scripts/nmap.py"
    fi
    
    # Message last
      print_message "$GREEN" "Nmap scan finished"
    # Go back to Project-Recon dir at last 
    cd $baseDir

done < $domainFile

}

# --- (Get ASN)(END)


# Call of Nmap ;)
getASN

