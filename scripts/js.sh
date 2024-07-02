#!/bin/bash

domainFile=$1

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


jsActive(){



}


# ---


while IFS= read -r domain; do 

    dir="results/$domain"
    cd $dir
    mkdir -p js
    # Message main
    printf '\t%s[%s]%s\t%s' "$ORANGE" "$domain" "$RESET" "$timeDate"

# subjs tool
  # Message
  print_message "$GREEN" "Gathering JS Urls from subjs tool"
  subjs -i urls.txt > subjs.txt
  cat subjs.txt | grep -F .js | cut -d "?" -f 1 | sort -u >>  jsUrlsPassive.txt
  sort -u jsUrlsPassive.txt -o jsUrls.txt

# Downloading JS files, from collected endpoints
    # Message
    print_message "$GREEN" "Saving JavaScript files locally"

# Calling bash file to download js files
    fetcher -u jsUrls.txt -t 120 -x 15 1> /dev/null
    # bash "$baseDir/scripts/jsRecon/downloadJS.sh" -f jsUrls.txt -t 10 -r 2 -x 12
    mv fetched js/fetched
    # Message
    print_message "$GREEN" "JS file collected: $(ls js/fetched | wc -l)"

    # Message
    print_message "$GREEN" "Extracting juicy stuff"

    (
        bash "$baseDir/scripts/jsRecon/main.sh" -dir=js/fetched
    ) &
    
    (
        echo "js/fetched" | nuclei -l jsUrls.txt -c 100 -retries 2 -t ~/nuclei-templates/exposures/ -o js/jsNuclei.txt
    ) &
    wait



    # Go back to Project-Recon dir at last 
    cd $baseDir

done < $domainFile