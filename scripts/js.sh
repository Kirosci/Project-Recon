#!/bin/bash


domainFile=$1

baseDir="$(pwd)"


while IFS= read -r domain; do 

    dir="results/$domain"
    cd $dir

    if ! [ -f "jsUrls.txt" ]; then
    
        cat urls.txt | grep -F .js | cut -d "?" -f 1 | sort -u | tee tmpJsUrls.txt 2> /dev/null 

        # Separating js urls 
        cat tmpJsUrls.txt | httpx -t 500 -mc 200 > jsUrls.txt

        mv tmpJsUrls.txt .tmp/urls 2> /dev/null

    fi

    bash "$baseDir/scripts/jsRecon/downloadJS.sh" -f jsUrls.txt -t 10 -r 2 -x 12
    wait


    sleep 10
    (
        bash "$baseDir/scripts/jsRecon/main.sh" -dir=js
    ) &
    
    (
        echo "js/jsSourceFiles" | nuclei -l jsUrls.txt -c 100 -retries 2 -t ~/nuclei-templates/exposures/ -o js/jsNuclei.txt
    ) &
    wait
    
    # Go back to Project-Recon dir at last 
    cd $baseDir

done < $domainFile