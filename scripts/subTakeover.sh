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
    rm subTakeovers.txt 2> /dev/null
    rm 404.txt 2> /dev/null

    # Message main
    printf '\t%s[%s]%s\t%s' "$ORANGE" "$domain" "$RESET" "$timeDate"

    # Read subdomains and filter out 404 ones
    cat "subdomains.txt" | httpx -mc 404 2> /dev/null | sed 's/https\?:\/\///' > 404.txt

    # Checking for cname of all filtered subdomains
    file="404.txt"
    while read -r line; do
    dig "$line" | grep -a "CNAME" | grep -a "$line" >> subTakeovers.txt 
    done <$file


    # Message
    print_message "$GREEN" "Subdomain Takeover found: "$(cat subTakeovers.txt 2> /dev/null | wc -l)""

    rm 404.txt

    # Go back to Project-Recon dir at last 
    cd $baseDir

done < $domainFile