#!/bin/bash

read domain
dir=$(head -1 $domain)
cd $dir || exit 1


(
dirsearch -l live_subdomains.txt  -w ~/wordlists/WordList/1.txt -t 10 -i 200 -o 1.txt
) &

(
dirsearch -l live_subdomains.txt  -w ~/wordlists/WordList/apac.txt -t 10 -i 200 -o apac.txt
) &

(
dirsearch -l live_subdomains.txt  -w ~/wordlists/WordList/cgi-bin.txt -t 10 -i 200 -o cgi-bin.txt
) &

(
dirsearch -l live_subdomains.txt  -w ~/wordlists/WordList/fuzz.txt -t 10 -i 200 -o fuzz.txt
) &

(
dirsearch -l live_subdomains.txt  -w ~/wordlists/WordList/god.txt -t 10 -i 200 -o god.txt
) &

(
dirsearch -l live_subdomains.txt  -w ~/wordlists/WordList/kibana.txt -t 10 -i 200 -o kibana.txt
) &

(
dirsearch -l live_subdomains.txt  -w ~/wordlists/WordList/xml.txt -t 10 -i 200 -o xml.txt
) &

(
dirsearch -l live_subdomains.txt  -w ~/wordlists/WordList/pl.txt -t 10 -i 200 -o pl.txt
) &

(
dirsearch -l live_subdomains.txt  -w ~/wordlists/WordList/fuzz-php.php -t 10 -i 200 -o fuzz-php.txt
) &

wait

cat 1.txt apac.txt cgi-bin.txt fuzz.txt god.txt kibana.txt xml.txt pl.txt fuzz-php.txt | sort -u > fuzz.txt

mkdir fuzz
mv 1.txt apac.txt cgi-bin.txt fuzz.txt god.txt kibana.txt xml.txt pl.txt fuzz-php.txt fuzz