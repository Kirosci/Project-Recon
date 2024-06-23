#!/bin/bash

domain=$1
dir=$(head -1 $domain)
cd $dir || exit 1
rm urls.txt 2> /dev/null
mkdir -p .tmp/urls


passive() {

(
    cat subdomains.txt | waybackurls > wayback_urls.txt 
) &

(
    cat subdomains.txt | gau > gau_urls.txt 
) &

(
    currentDir=$(pwd)
    sed 's/^https\?:\/\/\(www\.\)\?//' subdomains.txt > for_waymore.txt
    waymore -urlr 0 -mc 200 -r 2 -i for_waymore.txt -mode U -oU "$currentDir/waymore_urls.txt"
) &
wait

}

active() {
cat subdomains.txt | katana scan -duc -nc -silent -d 5 -aff -retry 2 -iqp -c 15 -p 15 -xhr -jc -kf -ef css,jpg,jpeg,png,svg,img,gif,mp4,flv,ogv,webm,webp,mov,mp3,m4a,m4p,scss,tif,tiff,ttf,otf,woff,woff2,bmp,ico,eot,htc,rtf,swf,image > katana_urls.txt

}


organise(){

cat wayback_urls.txt gau_urls.txt katana_urls.txt waymore_urls.txt | sort -u | httpx -t 500 -mc 200 -o urls.txt 2> /dev/null 

cat urls.txt | grep -F .js | cut -d "?" -f 1 | sort -u | tee tmpJsUrls.txt 2> /dev/null 

# Separating js urls 
cat tmpJsUrls.txt | httpx -t 500 -mc 200 > jsUrls.txt

# Moving unnecessary to .tmp dir
mv wayback_urls.txt gau_urls.txt katana_urls.txt waymore_urls.txt for_waymore.txt tmpJsUrls.txt .tmp/urls 2> /dev/null

#-----------------------------------------Organizing_Done---------------------------------------
}


if [ "$3" == "passive" ]; then

    passive
    organise

elif [ "$3" == "active" ]; then

    active
    organise

elif [ "$3" == "both" ]; then

    passive
    active
    organise

else

    passive
    organise

fi




