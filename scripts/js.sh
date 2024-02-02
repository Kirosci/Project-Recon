#!/bin/bash

read domain
dir=$(head -1 $domain)
cd $dir

cat urls.txt | grep -F .js | cut -d "?" -f 1 | sort -u | tee jsUrls.txt 1> /dev/null 




