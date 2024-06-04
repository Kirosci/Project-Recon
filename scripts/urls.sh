#!/bin/bash

read domain
dir=$(head -1 $domain)
cd $dir || exit 1
rm urls.txt 2> /dev/null


(
    cat subdomains.txt | waybackurls > .wayback_urls.txt 
) &

(
    cat subdomains.txt | gau > .gau_urls.txt 
) &

(  
    cat subdomains.txt | katana scan -duc -nc -silent -d 5 -aff -retry 2 -iqp -c 15 -p 15 -xhr -jc -kf -ef css,jpg,jpeg,png,svg,img,gif,mp4,flv,ogv,webm,webp,mov,mp3,m4a,m4p,scss,tif,tiff,ttf,otf,woff,woff2,bmp,ico,eot,htc,rtf,swf,image > .katana_urls.txt
) &

(
    currentDir=$(pwd)
    sed 's/^https\?:\/\/\(www\.\)\?//' subdomains.txt > .for_waymore.txt
    waymore -urlr 0 -mc 200 -r 2 -i .for_waymore.txt -mode U -oU "$currentDir/.waymore_urls.txt"
) &
wait


# cat ~/tools/waymore/results/*/waymore.txt | sort -u > .waymore_urls.txt

cat .wayback_urls.txt .gau_urls.txt .katana_urls.txt .waymore_urls.txt | sort -u | httpx -t 100 -mc 200 > urls.txt 2> /dev/null 

cat urls.txt | grep -F .js | cut -d "?" -f 1 | sort -u | tee .tmpJsUrls.txt 1> /dev/null 

#-------------------------------------URLs_Done------------------------------------------------

mv .wayback_urls.txt .gau_urls.txt .katana_urls.txt .waymore_urls.txt .for_waymore.txt .tmp/

#-----------------------------------------Organizing_Done---------------------------------------

cat .tmpJsUrls.txt | httpx -t 100 -mc 200 > jsUrls.txt
cd ../
