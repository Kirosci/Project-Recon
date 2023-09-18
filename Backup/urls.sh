#!/bin/bash

read dir
cd $dir

(
    cat live_subdomains.txt | waybackurls > wayback_urls.txt 
) &

(
    rm para.txt 2> /dev/null
    file="live_subdomains.txt"
    while read -r line; do
    python3 ~/tools/ParamSpider/paramspider.py -d $line 2> /dev/null | grep -E "https?://\S+" >> paramspider.txt
    done < $file
    rf -rf output/
)

(
    cat live_subdomains.txt | gau > gau_urls.txt 
) &

(
    cat live_subdomains.txt | katana scan --depth 3 > katana_urls.txt 2> /dev/null
) &

wait

cat wayback_urls.txt paramspider.txt gau_urls.txt katana_urls.txt | sort -u > urls.txt 2> /dev/null &

wait

#-------------------------------------URLs_Done------------------------------------------------


mv wayback_urls.txt paramspider.txt gau_urls.txt katana_urls.txt deep/


#-----------------------------------------Organizing_Done---------------------------------------


