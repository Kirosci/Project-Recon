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

passive() {
    (
        # if [ -f ".tmp/urls/wayback_urls.txt" ]; then
        #     print_message "$GREEN" "Waybackurls results are already there: $(cat '.tmp/urls/wayback_urls.txt' 2> /dev/null | wc -l)"
        # else
            cp subdomains.txt temp_subdomains_wayback.txt && 
            cat temp_subdomains_wayback.txt | waybackurls > wayback_urls.txt 2> /dev/null

            print_message "$GREEN" "Waybackurls: $(cat 'wayback_urls.txt' 2> /dev/null | wc -l)"
        # fi
    ) &
    (
        # if [ -f ".tmp/urls/gau_urls.txt" ]; then
        #     print_message "$GREEN" "Gau results are already there: $(cat '.tmp/urls/gau_urls.txt' 2> /dev/null | wc -l)"
        # else
            cp subdomains.txt temp_subdomains_gau.txt && 
            cat temp_subdomains_gau.txt | gau > gau_urls.txt 2> /dev/null

            print_message "$GREEN" "Gau: $(cat 'gau_urls.txt' 2> /dev/null | wc -l)"
        # fi
    ) &
    (
        # if [ -f ".tmp/urls/waymore_urls.txt" ]; then
        #     print_message "$GREEN" "Waymore results are already there: $(cat '.tmp/urls/waymore_urls.txt' 2> /dev/null | wc -l)"
        # else
            cp subdomains.txt temp_subdomains_waymore.txt && 
            cat temp_subdomains_waymore.txt | sed 's/^/https:\/\//' > for_waymore.txt
            waymore -n -xwm -urlr 0 -r 2 -i for_waymore.txt -mode U -oU waymore_urls.txt 2> /dev/null 1> /dev/null

            print_message "$GREEN" "Waymore: $(cat 'waymore_urls.txt' 2> /dev/null | wc -l)"
        # fi
    ) &
    wait

    rm temp_subdomains_wayback.txt temp_subdomains_gau.txt temp_subdomains_waymore.txt 2> /dev/null
}

# ---

active() {
    (
        # if [ -f ".tmp/urls/katana_urls.txt" ]; then
        #     print_message "$GREEN" "Katana results are already there: $(cat '.tmp/urls/katana_urls.txt' 2> /dev/null | wc -l)"
        # else
            cat subdomains.txt | katana scan -hl -duc -nc -silent -d 5 -aff -retry 2 -iqp -c 20 -p 20 -xhr -jc -kf -ef css,jpg,jpeg,png,svg,img,gif,mp4,flv,ogv,webm,webp,mov,mp3,m4a,m4p,scss,tif,tiff,ttf,otf,woff,woff2,bmp,ico,eot,htc,rtf,swf,image -o katana_urls.txt 2> /dev/null 1> /dev/null

            print_message "$GREEN" "Katana: $(cat 'katana_urls.txt' 2> /dev/null | wc -l)"
        # fi
    ) &

    (
        # if [ -f ".tmp/urls/hakrawler_urls.txt" ]; then
        #     print_message "$GREEN" "Hakrawler results are already there: $(cat '.tmp/urls/hakrawler_urls.txt' 2> /dev/null | wc -l)"
        # else
            cat urls.txt | hakrawler -d 5 -insecure -subs -t 40 > hakrawler_urls.txt 2> /dev/null

            print_message "$GREEN" "Hakrawler: $(cat 'hakrawler_urls.txt' 2> /dev/null | wc -l)"
        # fi
    ) &


}

# ---

organise(){
    # Filtering url with 200 OK
    print_message "$GREEN" "Organising collected urls"
    cat wayback_urls.txt gau_urls.txt waymore_urls.txt katana_urls.txt hakrawler_urls.txt 2> /dev/null | sort -u >> urls.txt
    cat .tmp/urls/wayback_urls.txt .tmp/urls/gau_urls.txt .tmp/urls/waymore_urls.txt .tmp/urls/katana_urls.txt .tmp/urls/hakrawler_urls.txt 2> /dev/null | sort -u >> urls.txt

    sort -u urls.txt -o urls.txt 1> /dev/null
    # Separating Js and json urls
    cat urls.txt | grep -F .js | cut -d "?" -f 1 | sort -u > tmpJsUrls.txt 1> /dev/null
    # Separating js urls 
    cat tmpJsUrls.txt | httpx -t 100 -mc 200 -o jsUrlsPassive.txt 2> /dev/null 1> /dev/null
    # Moving unnecessary to .tmp dir
    mv wayback_urls.txt gau_urls.txt waymore_urls.txt katana_urls.txt hakrawler_urls.txt for_waymore.txt tmpJsUrls.txt .tmp/urls/ 2> /dev/null
    print_message "$GREEN" "Organising finished"
}

# ---

# Used for-loop specifically, don't switch to while-loop, it was having some problems with waymore tool
for domain in $(cat "$domainFile"); do
    dir="results/$domain"
    cd "$dir"
    mkdir -p .tmp/urls/


    # Message main
    printf '\t%s[%s]%s\t%s' "$ORANGE" "$domain" "$RESET" "$timeDate"

    if ! [[ "$(cat urls.txt|wc -l)" -eq 0 ]]; then
        print_message "$GREEN" "URL results are already there: $(cat 'urls.txt' 2> /dev/null | wc -l)"
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
    printf '\t%s[Found: %s]%s\t%s' "$GREEN" "$(cat urls.txt 2> /dev/null | wc -l)" "$RESET" "$timeDate"
    # Go back to base directory at last 
    cd "$baseDir"
done