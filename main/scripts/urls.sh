#!/bin/bash

read domain
dir=$(head -1 $domain)
cd $dir || exit 1

(
    cat live_subdomains.txt | waybackurls > wayback_urls.txt 
) &

(
    rm para.txt 2> /dev/null
    file="live_subdomains.txt"
    while read -r line; do
    python3 ~/tools/ParamSpider/paramspider.py -d $line 2> /dev/null | grep -E "https?://\S+" >> paramspider.txt
    done < $file
    rm -rf output/
) &

(
    cat live_subdomains.txt | gau > gau_urls.txt 
) &

(
    cat live_subdomains.txt | katana scan --depth 3 > katana_urls.txt 2> /dev/null
) &

wait

cat wayback_urls.txt paramspider.txt gau_urls.txt katana_urls.txt | sort -u > urls.txt 2> /dev/null &

wait

cat urls.txt | grep -F .js | cut -d "?" -f 1 | sort -u | tee jsUrls.txt 1> /dev/null 

#-------------------------------------URLs_Done------------------------------------------------


mv wayback_urls.txt paramspider.txt gau_urls.txt katana_urls.txt deep/

rm -rf deep

#-----------------------------------------Organizing_Done---------------------------------------


