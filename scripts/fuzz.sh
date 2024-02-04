#!/bin/bash

read domain
dir=$(head -1 $domain)
cd $dir || exit 1


(
dirsearch -l subdomains.txt  -w wordlists/mixedBig.txt -t 50 -i 200 -o fuzz_mixedBig.txt
) &

(
dirsearch -l subdomains.txt  -w wordlists/dirSmall.txt -t 50 -i 200 -o fuzz_dirSmall.txt
) &

wait

cat fuzz_mixedBig.txt fuzz_dirSmall.txt | sort -u | fuzz.txt

mkdir fuzz
mv fuzz_mixedBig.txt fuzz/
mv fuzz_dirSmall.txt fuzz/