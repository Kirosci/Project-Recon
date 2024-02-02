#!/bin/bash

read domain
dir=$(head -1 $domain)
cd $dir

nuclei -l jsUrls.txt -t ~/nuclei-templates/exposures/ -o js_bugs.txt



