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

    if [ -f "xss.txt" ]; then
        print_message "$GREEN" "XSS results are already there: "$(cat xss.txt 2> /dev/null | wc -l)""
    else
        cat "urls.txt" | grep = | kxss | grep '>\|<\|"' > xss.txt

        # Message
        if ! [ $(wc -l < "xss.txt") -eq 0 ]; then
            print_message "$GREEN" "Potentially vulnerable found: "$(cat xss.txt 2> /dev/null | wc -l)""
        else
            rm xss.txt 2> /dev/null
        fi
    fi

    # Go back to Project-Recon dir at last 
    cd $baseDir
done < $domainFile
