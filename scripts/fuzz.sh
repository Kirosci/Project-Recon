#!/bin/bash


domainFile=$1

baseDir="$(pwd)"


while IFS= read -r domain; do 

    dir="results/$domain"
    cd $dir


    (
    dirsearch -l subdomains.txt  -w wordlists/mixedMedium.txt -t 10 -i 200 -o fuzz_mixedBig.txt
    ) &

    (
    dirsearch -l subdomains.txt  -w wordlists/dirSmall.txt -t 10 -i 200 -o fuzz_dirSmall.txt
    ) &

    wait

    cat fuzz_mixedBig.txt fuzz_dirSmall.txt | sort -u | fuzz.txt

    mkdir fuzz
    mv fuzz_mixedBig.txt fuzz/
    mv fuzz_dirSmall.txt fuzz/

    # Go back to Project-Recon dir at last 
    cd $baseDir

done < $domainFile