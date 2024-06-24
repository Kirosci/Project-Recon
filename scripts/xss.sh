#!/bin/bash

domainFile=$1

baseDir="$(pwd)"

while IFS= read -r domain; do 

    dir="results/$domain"
    cd $dir
    rm xss.txt 2> /dev/null

    cat "urls.txt" | grep = | kxss | grep '>\|<\|"' > xss.txt

    # Go back to Project-Recon dir at last 
    cd $baseDir

done < $domainFile
