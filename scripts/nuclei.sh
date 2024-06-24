#!/bin/bash


domainFile=$1

baseDir="$(pwd)"


while IFS= read -r domain; do 

    dir="results/$domain"
    cd $dir

    rm nuclei.txt 2> /dev/null

    nuclei -l subdomains.txt -c 50 -fr -rl 20 -timeout 20 -o nuclei.txt -t cent-nuclei-templates

    # Go back to Project-Recon dir at last 
    cd $baseDir

done < $domainFile