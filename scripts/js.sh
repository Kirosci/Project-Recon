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

# ---


while IFS= read -r domain; do 

    dir="results/$domain"
    cd $dir

    # Message main
    printf '\t%s[%s]%s\t%s' "$ORANGE" "$domain" "$RESET" "$timeDate"

# Checking if jsUrls doesn't exists
    if ! [ -f "jsUrls.txt" ]; then
    

        # Message
        print_message "$ORANGE" "jsUrls.txt not found, creating..."

        cat urls.txt | grep -F .js | cut -d "?" -f 1 | sort -u | tee tmpJsUrls.txt 2> /dev/null 1> /dev/null 

        # Separating js urls 
        cat tmpJsUrls.txt | httpx -t 100 -mc 200 > jsUrls.txt 2> /dev/null

        # Message
        print_message "$GREEN" "Created jsUrls.txt, Lines: "$(cat jsUrls.txt 2> /dev/null | wc -l)""

        mv tmpJsUrls.txt .tmp/urls 2> /dev/null

    fi


# Downloading JS files, from collected endpoints

    # Message
    print_message "$GREEN" "Saving JavaScript files locally"

# Calling bash file to download js files
    bash "$baseDir/scripts/jsRecon/downloadJS.sh" -f jsUrls.txt -t 10 -r 2 -x 12
    wait

    # Message
    print_message "$GREEN" "JS file collected: $(ls js/jsSourceFiles | wc -l)"

    sleep 10

    # Message
    print_message "$GREEN" "Extracting juicy stuff"

    (
        bash "$baseDir/scripts/jsRecon/main.sh" -dir=js
    ) &
    
    (
        echo "js/jsSourceFiles" | nuclei -l jsUrls.txt -c 100 -retries 2 -t ~/nuclei-templates/exposures/ -o js/jsNuclei.txt
    ) &
    wait


    # Go back to Project-Recon dir at last 
    cd $baseDir

done < $domainFile