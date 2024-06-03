#!/bin/bash

read domain
dir=$(head -1 $domain)
cd $dir || exit 1
rm urls.txt 2> /dev/null


(
    cat subdomains.txt | waybackurls > wayback_urls.txt 
) &

# (
#     rm para.txt 2> /dev/null
#     file="live_subdomains.txt"
#     while read -r line; do
#     python3 ~/tools/ParamSpider/paramspider.py -d $line 2> /dev/null | grep -E "https?://\S+" >> paramspider.txt
#     done < $file
#     rm -rf output/
# ) &

(
    cat subdomains.txt | gau > gau_urls.txt 
) &

(  
    cat subdomains.txt | katana scan -duc -nc -silent -d 5 -aff -retry 2 -iqp -c 15 -p 15 -xhr -jc -kf -ef css,jpg,jpeg,png,svg,img,gif,mp4,flv,ogv,webm,webp,mov,mp3,m4a,m4p,scss,tif,tiff,ttf,otf,woff,woff2,bmp,ico,eot,htc,rtf,swf,image > katana_urls.txt
) &

(
    # mkdir ~/tools/waymore/old_results 2> /dev/null
    # rsync -av ~/tools/waymore/results/ ~/tools/waymore/old_results/ 1&>2 /dev/null
    # rm -rf ~/tools/waymore/results
    # mkdir ~/tools/waymore/results
    currentDir=$(pwd)
    sed 's/^https\?:\/\/\(www\.\)\?//' subdomains.txt > for_waymore.txt
    python3 ~/tools/waymore/waymore.py -urlr 0 -mc 200 -r 2 -i for_waymore.txt -mode U -oU "$currentDir/waymore_urls.txt"
) &
wait


# cat ~/tools/waymore/results/*/waymore.txt | sort -u > waymore_urls.txt

cat wayback_urls.txt gau_urls.txt katana_urls.txt waymore_urls.txt | sort -u | httpx -t 100 -mc 200 > urls.txt 2> /dev/null 

cat urls.txt | grep -F .js | cut -d "?" -f 1 | sort -u | tee jsurls.txt 1> /dev/null 

#-------------------------------------URLs_Done------------------------------------------------



wc -l * | awk '{print$2}' > filelist.txt

if [ ! -f "filelist.txt" ]; then
    echo "Error: filelist.txt not found."
    exit 1
fi
# Loop through each filename in filelist.txt
while IFS= read -r filename; do
    # Check if the file exists and remove it if it does
    if [ -f "$filename" ]; then
        rm "$filename"
        echo "Removed file: $filename"
    else
        echo "File not found: $filename"
    fi

done < "filelist.txt"


rm wayback_urls.txt gau_urls.txt katana_urls.txt waymore_urls.txt for_waymore.txt filelist.txt

#-----------------------------------------Organizing_Done---------------------------------------

cat jsurls.txt | httpx -t 100 -mc 200 > jsUrls.txt
cd ../
