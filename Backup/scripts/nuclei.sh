read domain
dir=$(head -1 $domain)
cd $dir

rm nuclei.txt 2> /dev/null

nuclei -l subdomains.txt 2> /dev/null > nuclei.txt 