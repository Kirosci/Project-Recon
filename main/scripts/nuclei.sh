#!/bin/bash

read domain
dir=$(head -1 $domain)
cd $dir || exit 1

rm nuclei.txt 2> /dev/null

nuclei -l subdomains.txt 2> /dev/null > nuclei.txt 

