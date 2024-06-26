#!/bin/bash

domainFile=$1

baseDir="$(pwd)"

GREEN="\e[32m"
RED="\e[31m"
ORANGE="\e[38;5;214m"
RESET="\e[0m"

timeDate=$(echo -e "${ORANGE}[$(date "+%H:%M:%S : %D")]\n${RESET}")
time=$(echo -e "${ORANGE}[$(date "+%H:%M:%S")]\n${RESET}")

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

passive() {
    (
        if [ -f ".tmp/urls/wayback_urls.txt" ]; then
            echo -e "\t\t|---${GREEN}[Waybackurls results are already there: $(cat '.tmp/urls/wayback_urls.txt' | wc -l)]${RESET} \t$time"
        else
            cat subdomains.txt | waybackurls > wayback_urls.txt 2> /dev/null
            echo -e "\t\t|---${GREEN}[Waybackurls: $(wc -l wayback_urls.txt | awk '{print$1}')]${RESET} \t$time"
        fi
    ) &
    (
        if [ -f ".tmp/urls/gau_urls.txt" ]; then
            echo -e "\t\t|---${GREEN}[Gau results are already there: $(cat '.tmp/urls/gau_urls.txt' | wc -l)]${RESET} \t$time"
        else
            cat subdomains.txt | gau > gau_urls.txt 2> /dev/null
            echo -e "\t\t|---${GREEN}[Gau: $(wc -l gau_urls.txt | awk '{print$1}')]${RESET} \t$time"
        fi
    ) &
    (
        if [ -f ".tmp/urls/waymore_urls.txt" ]; then
            echo -e "\t\t|---${GREEN}[Waymore results are already there: $(cat '.tmp/urls/waymore_urls.txt' | wc -l)]${RESET} \t$time"
        else
            cat subdomains.txt | sed 's/^/https:\/\//' > for_waymore.txt
            waymore -n -xwm -urlr 0 -r 2 -i for_waymore.txt -mode U -oU waymore_urls.txt 2> /dev/null 1> /dev/null
            echo -e "\t\t|---${GREEN}[Waymore: $(wc -l waymore_urls.txt | awk '{print$1}')]${RESET} \t$time"
        fi
    ) &
    wait
}

# ---

active() {
    if [ -f ".tmp/urls/katana_urls.txt" ]; then
        echo -e "\t\t|---${GREEN}[Katana results are already there: $(cat '.tmp/urls/katana_urls.txt' | wc -l)]${RESET} \t$time"
    else
        cat subdomains.txt | katana scan -duc -nc -silent -d 5 -aff -retry 2 -iqp -c 15 -p 15 -xhr -jc -kf -ef css,jpg,jpeg,png,svg,img,gif,mp4,flv,ogv,webm,webp,mov,mp3,m4a,m4p,scss,tif,tiff,ttf,otf,woff,woff2,bmp,ico,eot,htc,rtf,swf,image > katana_urls.txt
        echo -e "\t\t|---${GREEN}[Katana: $(wc -l katana_urls.txt | awk '{print$1}')]${RESET} \t$time"
    fi
}

# ---

organise(){
    # Filtering url with 200 OK
    cat wayback_urls.txt gau_urls.txt waymore_urls.txt katana_urls.txt 2> /dev/null | sort -u >> urls.txt
    cat .tmp/urls/wayback_urls.txt .tmp/urls/gau_urls.txt .tmp/urls/waymore_urls.txt .tmp/urls/katana_urls.txt 2> /dev/null | sort -u >> urls.txt

    sort -u urls.txt -o urls.txt 1> /dev/null
    # Separating Js and json urls
    cat urls.txt | grep -F .js | cut -d "?" -f 1 | sort -u > tmpJsUrls.txt 1> /dev/null
    # Separating js urls 
    cat tmpJsUrls.txt | httpx -t 100 -mc 200 -o jsUrls.txt 2> /dev/null 1> /dev/null
    # Moving unnecessary to .tmp dir
    mv wayback_urls.txt gau_urls.txt waymore_urls.txt katana_urls.txt for_waymore.txt tmpJsUrls.txt .tmp/urls/ 2> /dev/null
}

# ---

# Used for-loop specifically, don't switch to while-loop, it was having some problems with waymore tool
for domain in $(cat "$domainFile"); do
    dir="results/$domain"
    cd "$dir"
    mkdir -p .tmp/urls/


    # Message main
    echo -e "\t${ORANGE}[$domain]${RESET} \t$timeDate"

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

    # Message last
    echo -e "\t${GREEN}[Found: $(wc -l urls.txt | awk '{print$1}')]${RESET} \t$timeDate"
    # Go back to base directory at last 
    cd "$baseDir"
done