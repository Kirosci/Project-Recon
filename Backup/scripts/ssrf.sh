#!/bin/bash

domainFile=$1
link=$2

baseDir="$(pwd)"

# ---

GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
ORANGE=$(tput setaf 3)
RESET=$(tput sgr0) 

timeDate=$(echo -e "${ORANGE}[$(date "+%H:%M:%S : %D")]\n${RESET}")
time=$(echo -e "${ORANGE}[$(date "+%H:%M:%S")]\n${RESET}")

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

while IFS= read -r domain; do 

    dir="results/$domain"
    cd $dir
    file="urls.txt"

    # Message main
    printf '\t%s[%s]%s\t%s' "$ORANGE" "$domain" "$RESET" "$timeDate"

    if [ -f "ssrfUrls.txt" ]; then
        # Message
        print_message "$GREEN" "SSRF results are already saved"
    else
        # For getting firdst 20 charachters of $link so we can grep for it to get proper open redirects.
        first_20="${link:0:20}"


        counter=1

        while read -r line; do
            lc=$link?no=$counter
            qs=$(echo "$line" | grep = | qsreplace -a | qsreplace $lc | awk NF |sort -u | tee -a ssrfUrls.txt)  # Use the counter in the query
            headers=$(curl -I -L "$qs" -k 2> /dev/null)
            location_header=$(echo "$headers" | grep -i "location:" 2> /dev/null)
            if [ -n "$location_header" ]; then
              url=$(echo "$location_header" | awk '{print $2}')
              echo "$qs ---> $url" >> openredirectUrls.txt
            fi

            counter=$((counter+1))
        done < "$file"

        # Filtering out proper Open Redirects
        cat openredirectUrls.txt 2> /dev/null | grep -- "---> $first_20" > openRedirects.txt 

        if ! [ $(wc -l < "openRedirects.txt") -eq 0 ]; then
            # Message
            print_message "$GREEN" "Open redirects found: "$(cat openRedirects.txt 2> /dev/null | wc -l)""
        else
            rm openRedirects.txt 2> /dev/null
        fi  

        rm openredirectUrls.txt 2> /dev/null
    fi    

    # Go back to Project-Recon dir at last 
    cd $baseDir
done < $domainFile