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

passive() {
    (
        cat subdomains.txt | waybackurls > wayback_urls.txt 2> /dev/null
        echo -e "\t\t|---${GREEN}[Waybackurls: $(wc -l wayback_urls.txt | awk '{print$1}')]${RESET} \t$time"
    ) &
    (
        cat subdomains.txt | gau > gau_urls.txt 2> /dev/null
        echo -e "\t\t|---${GREEN}[Gau: $(wc -l gau_urls.txt | awk '{print$1}')]${RESET} \t$time"
    ) &
    (
        cat subdomains.txt | sed 's/^/https:\/\//' > for_waymore.txt
        waymore -n -xwm -urlr 0 -r 2 -i for_waymore.txt -mode U -oU waymore_urls.txt 2> /dev/null 1> /dev/null
        echo -e "\t\t|---${GREEN}[Waymore: $(wc -l waymore_urls.txt | awk '{print$1}')]${RESET} \t$time"
    ) &
    wait
}

# ---

active() {
    cat subdomains.txt | katana scan -duc -nc -silent -d 5 -aff -retry 2 -iqp -c 15 -p 15 -xhr -jc -kf -ef css,jpg,jpeg,png,svg,img,gif,mp4,flv,ogv,webm,webp,mov,mp3,m4a,m4p,scss,tif,tiff,ttf,otf,woff,woff2,bmp,ico,eot,htc,rtf,swf,image > katana_urls.txt
    echo -e "\t\t|---${GREEN}[Katana: $(wc -l katana_urls.txt | awk '{print$1}')]${RESET} \t$time"
}

# ---

organise(){
    # Filtering url with 200 OK
    cat wayback_urls.txt gau_urls.txt waymore_urls.txt katana_urls.txt 2> /dev/null | sort -u > urls.txt
    # Separating Js and json urls
    cat urls.txt | grep -F .js | cut -d "?" -f 1 | sort -u > tmpJsUrls.txt 1> /dev/null
    # Separating js urls 
    cat tmpJsUrls.txt | httpx -t 100 -mc 200 -o jsUrls.txt 2> /dev/null 1> /dev/null
    # Moving unnecessary to .tmp dir
    mkdir -p .tmp/urls/
    mv wayback_urls.txt gau_urls.txt waymore_urls.txt katana_urls.txt for_waymore.txt tmpJsUrls.txt .tmp/urls/ 2> /dev/null
}

# ---

for domain in $(cat "$domainFile"); do
    dir="results/$domain"
    cd "$dir"
    rm urls.txt 2> /dev/null
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
    echo -e "\t${GREEN}[Found: $(wc -l urls.txt | awk '{print$1}')]${RESET} \t$timeDate"
    # Go back to base directory at last 
    cd "$baseDir"
done