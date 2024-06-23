#!/bin/bash

read domain
dir=$(head -1 $domain)
cd $dir || exit 1
currentDir=$(pwd)

# mkdir js

# (
#     nuclei -l jsUrls.txt -c 100 -retries 2 -t ~/nuclei-templates/exposures/ -o js/jsNuclei.txt
# )&

(
bash "$currentDir/../scripts/jsRecon/downloadJS.sh" -f jsUrls.txt -t 10 -r 2 -x 12
)& 
wait

sleep 10
bash "$currentDir/../scripts/jsRecon/main.sh" -dir=js