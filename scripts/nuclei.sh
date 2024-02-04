#!/bin/bash

read domain
dir=$(head -1 $domain)
cd $dir || exit 1

rm nuclei.txt 2> /dev/null

nuclei -l subdomains.txt -fr -rl 20 -timeout 20 -o nuclei.txt -t cent-nuclei-templates

