#!/bin/bash


if [ -z "$2" ]; then
    timeout="30"
else
    timeout="$2"
fi

domain=$1

dir=$(head -1 $domain)

wordlistsDir="$(pwd)/wordlists"

mkdir "$dir" 2> /dev/null

cp $domain $dir
cd $dir || exit 1

mkdir -p .tmp/.subdomains
mkdir -p .tmp/.subdomains/.passive
mkdir -p .tmp/.subdomains/.active


rm subdomains.txt 2> /dev/null
rm liveSubdomains.txt 2> /dev/null

passiveEnumeration(){
(
  cat "$domain" | assetfinder >> .assetfinderSubdomains.txt
  lines=$(cat .assetfinderSubdomains.txt | wc -l)
  echo -e "    |---\e[32m[Assetfinder Done] [Lines: $lines]\e[0m"
) &

(
  cat "$domain" | haktrails subdomains >> .haktrailsSubdomains.txt
  lines=$(cat .haktrailsSubdomains.txt | wc -l)
  echo -e "    |---\e[32m[Haktrails Done] [Lines: $lines]\e[0m"
) &

(
  cat "$domain" | subfinder -o .subfinderSubdomains.txt
  lines=$(cat .subfinderSubdomains.txt | wc -l)
  echo -e "    |---\e[32m[Subfinder Done] [Lines: $lines]\e[0m"
) &

(
  subdominator -dL "$domain" -o .subdominatorSubdomains.txt
  lines=$(cat .subdominatorSubdomains.txt | wc -l)
  echo -e "    |---\e[32m[Subdominator Done] [Lines: $lines]\e[0m" 
) &


(

  if [[ "$2" -eq 1 ]]; then
    amass enum -df "$domain" -o .amassSubdomains.txt
    lines=$(cat .amassSubdomains.txt | wc -l)
    echo -e "    |---\e[32m[Amass Done [Lines: $lines]]\e[0m"

  elif [[ "$2" -eq 0 ]]; then
  echo -e "    |---\e[32m[Excluded Amass]\e[0m"
  cat "$domain" | tee .amassSubdomains.txt

  else
    amass enum -df "$domain" -timeout $timeout -o .amassSubdomains.txt
    lines=$(cat .amassSubdomains.txt | wc -l)
    echo -e "    |---\e[32m[Amass Done] [Timeout: $2 minutes] [Lines: $lines]\e[0m" 
  fi

) &

wait

#----------------------------Sorting Assets-----------------------------------------

cat .assetfinderSubdomains.txt .subdominatorSubdomains.txt .amassSubdomains.txt .haktrailsSubdomains.txt .subfinderSubdomains.txt | sort -u > .passiveSubdomains.txt

}

activeEnumeration() { 


(
  # Dnsgen will take list of subdomains (.passiveSubdomains.txt) and will permute between them

  cat ".passiveSubdomains.txt" | dnsgen - | tee -a .dnsgen.txt 2> err
  lines=$(cat .dnsgen.txt | wc -l)
  echo -e "    |---\e[32m[Dnsgen Done] [Lines: $lines]\e[0m"
) &

(
  # Alterx takes subdomains (.passiveSubdomains.txt) and will permute between them, on behalf of specified rules
  cat ".passiveSubdomains.txt" | alterx -o .alterx.txt 2> err
  lines=$(cat .alterx.txt | wc -l)
  echo -e "    |---\e[32m[Alterx Done] [Lines: $lines]\e[0m"
) &

(
  # Altdns will permute assetnote wordlist with domain name

  altdns -i "$domain" -w "$wordlistsDir/assetnoteSubdomains.txt" -o .altdns.txt 2> err
  lines=$(cat .altdns.txt | wc -l)
  echo -e "    |---\e[32m[Altdns (Assetnote wordlist) Done] [Lines: $lines]\e[0m"
) & 

wait

cat .dnsgen.txt .alterx.txt .altdns.txt | sort -u | tee -a .totalPermuted.txt 2> err


# Puredns will resolve the permuted subdomains 
puredns resolve ".totalPermuted.txt" -q | tee -a .activeSubdomains.txt
lines=$(cat .activeSubdomains.txt | wc -l)
echo -e "    |---\e[32m[Active Enumeration Done] [Active Subdomains: $lines]\e[0m"


}


checkWordlist() {

  # Getting wordlist name to know it's last updated date
  wordlistDate=$(ls $wordlistsDir | grep httparchive_subdomains | sed -e 's/httparchive_subdomains_//' -e 's/.txt//')
  currentDate=$(date +%Y_%m_%d)

  # Convert the dates to the format YYYYMMDD for comparison
  wordlistDate_converted=$(date -d "${wordlistDate//_/}" +%Y%m%d)
  currentDate_converted=$(date -d "${currentDate//_/}" +%Y%m%d)

  # Compare the dates
  if [ "$wordlistDate_converted" -gt "$currentDate_converted" ]; then
    # Wordlist is the latest on good to go
    activeEnumeration    
  elif [ "$wordlistDate_converted" -lt "$currentDate_converted" ]; then
    # Updating the wordlist
    cd $wordlistsDir
    wget "wget https://wordlists-cdn.assetnote.io/data/automated/httparchive_subdomains_$(date +%Y)_$(date +%m)_28.txt"
    rm assetnoteSubdomains.txt 2> /dev/null
    cat "httparchive_subdomains_$(date +%Y)_$(date +%m)_28.txt" "2m-subdomains.txt" | sort -u | tee -a assetnoteSubdomains.txt
    cd $dir
  else
    # Wordlist is the latest on good to go
    activeEnumeration
  fi


}

passiveEnumeration
checkWordlist

cat .passiveSubdomains.txt .activeSubdomains.txt | sort -u | tee -a subdomains.txt

# Organising
mv .assetfinderSubdomains.txt .subdominatorSubdomains.txt .amassSubdomains.txt .haktrailsSubdomains.txt .subfinderSubdomains.txt .tmp/.subdomains/.passive

mv .dnsgen.txt .alterx.txt .altdns.txt .totalPermuted.txt .tmp/.subdomains/.active


# Filtering out false positives

# file1="$domain"
# file2=".passiveSubdomains.txt"




# while IFS= read -r word; do
#     grep -E "\\b${word//./\\.}\\b" "$file2" | awk '{print$1}' | sort -u >> ".subdomain.txt"
# done < "$file1"






# cat .subdomain.txt | httpx -t 100 -mc 200,201,202,300,301,302,303,400,401,402,403,404 | tee subdomains.txt 

#---------------------------Organizing Assets---------------------------------------

# mv .subdomain.txt .passiveSubdomains.txt .assetfinderSubdomains.txt .subdominatorSubdomains.txt .amassSubdomains.txt .haktrailsSubdomains.txt .subfinderSubdomains.txt .tmp/

#-----------------------------Finding Live Subdomains-------------------------------

# cat subdomains.txt | httpx > liveSubdomains.txt 2> /dev/null


# Use "chmod 777 script.sh" to give it permissions for soomth run

