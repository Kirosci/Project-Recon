#!/bin/bash


if [[ -z "$2" ]]; then
    timeout="$2"
else
    timeout="0"
fi


domain=$1

dir=$(head -1 $domain)
dir=$(readlink -f "$dir")
wordlistsDir="$(pwd)/wordlists"

mkdir "$dir" 2> /dev/null

cp $domain $dir
cd $dir || exit 1

mkdir -p .tmp/subdomains
mkdir -p .tmp/subdomains/passive
mkdir -p .tmp/subdomains/active


rm subdomains.txt 2> /dev/null
rm liveSubdomains.txt 2> /dev/null


passiveEnumeration(){
(
  cat "$domain" | assetfinder >> assetfinderSubdomains.txt
  lines=$(cat assetfinderSubdomains.txt | wc -l)
  echo -e "    |---\e[32m[Assetfinder Done] [Lines: $lines]\e[0m"
) &

(
  cat "$domain" | haktrails subdomains >> haktrailsSubdomains.txt
  lines=$(cat haktrailsSubdomains.txt | wc -l)
  echo -e "    |---\e[32m[Haktrails Done] [Lines: $lines]\e[0m"
) &

(
  cat "$domain" | subfinder -o subfinderSubdomains.txt
  lines=$(cat subfinderSubdomains.txt | wc -l)
  echo -e "    |---\e[32m[Subfinder Done] [Lines: $lines]\e[0m"
) &

(
  subdominator -dL "$domain" -o subdominatorSubdomains.txt
  lines=$(cat subdominatorSubdomains.txt | wc -l)
  echo -e "    |---\e[32m[Subdominator Done] [Lines: $lines]\e[0m" 
) &


(

  if [[ "$2" -eq 1 ]]; then
    amass enum -df "$domain" -o amassSubdomains.txt
    lines=$(cat amassSubdomains.txt | wc -l)
    echo -e "    |---\e[32m[Amass Done [Lines: $lines]]\e[0m"

  elif [[ "$2" -eq 0 ]]; then
  echo -e "    |---\e[32m[Excluded Amass]\e[0m"
  cat "$domain" | tee amassSubdomains.txt

  else
    amass enum -df "$domain" -timeout $timeout -o amassSubdomains.txt
    lines=$(cat amassSubdomains.txt | wc -l)
    echo -e "    |---\e[32m[Amass Done] [Timeout: $2 minutes] [Lines: $lines]\e[0m" 
  fi

) &

wait

#----------------------------Sorting Assets-----------------------------------------

cat assetfinderSubdomains.txt subdominatorSubdomains.txt amassSubdomains.txt haktrailsSubdomains.txt subfinderSubdomains.txt | sort -u > combinedPassiveSubdomains.txt

# Filtering out false positives

file1="$domain"
file2="combinedPassiveSubdomains.txt"


while IFS= read -r word; do
    grep -E "\\b${word//./\\.}\\b" "$file2" | awk '{print$1}' | sort -u >> "passiveSubdomains.txt"
done < "$file1"

  cat activeSubdomains.txt passiveSubdomains.txt | sort -u | tee -a active+passive.txt 2> /dev/null

}

activeEnumeration() { 


  # Getting wordlist name to know it's last updated date
  wordlistDate=$(ls $wordlistsDir | grep httparchive_subdomains | sed -e 's/httparchive_subdomains_//' -e 's/.txt//')
  currentDate=$(date +%Y_%m_%d)

  # Convert the dates to the format YYYYMMDD for comparison
  wordlistDate_converted=$(date -d "${wordlistDate//_/}" +%Y%m%d)
  currentDate_converted=$(date -d "${currentDate//_/}" +%Y%m%d)

# Downloading '2m-subdomains.txt' wordlist if not there
  cd $wordlistsDir
  if ! [ -f "2m-subdomains.txt" ]; then
  wget "https://wordlists-cdn.assetnote.io/data/manual/2m-subdomains.txt"
  fi
  cd $dir
  
# Downloading in http_archive wordlist is not there
  cd $wordlistsDir
  wordlistName=$(ls | grep httparchive_subdomains_)
  if ! [ -f $wordlistName ]; then
    wget "https://wordlists-cdn.assetnote.io/data/automated/httparchive_subdomains_$(date +%Y)_$(date +%m)_28.txt"
    rm assetnoteSubdomains.txt 2> /dev/null
    cat "httparchive_subdomains_$(date +%Y)_$(date +%m)_28.txt" "2m-subdomains.txt" | sort -u | tee -a assetnoteSubdomains.txt
  else
    # Updating http_archive wordlist if exists
    if [ "$wordlistDate_converted" -lt "$currentDate_converted" ]; then

      if [ $(date +%d) -gt 27 ]; then
        # Updating the wordlist, If last updated date of wordlist is earlier than current date and if current date is greatter than 27
        rm httparchive_subdomains_*
        wget "https://wordlists-cdn.assetnote.io/data/automated/httparchive_subdomains_$(date +%Y)_$(date +%m)_28.txt"
        rm assetnoteSubdomains.txt 2> /dev/null
        cat "httparchive_subdomains_$(date +%Y)_$(date +%m)_28.txt" "2m-subdomains.txt" | sort -u | tee -a assetnoteSubdomains.txt
      fi
    fi
  fi
  cd $dir

# Generating 'assetnoteSubdomains' wordlist if not there
  cd $wordlistsDir
  if ! [ -f "assetnoteSubdomains.txt" ]; then
  cat httparchive_subdomains_* 2m-subdomains.txt | sort -u | tee -a assetnoteSubdomains.txt
  fi
  cd $dir




  # (
  #   # Dnsgen will take list of subdomains (passiveSubdomains.txt) and will permute between them

  #   dnsgen "passiveSubdomains.txt" -f | tee -a dnsgen.txt
  #   lines=$(cat dnsgen.txt | wc -l)
  #   echo -e "    |---\e[32m[Dnsgen Done] [Lines: $lines]\e[0m"
  # ) &

  (
    # Alterx takes subdomains (passiveSubdomains.txt) and will permute between them, on behalf of specified rules
    cat "passiveSubdomains.txt" | alterx -o alterx.txt
    lines=$(cat alterx.txt | wc -l)
    echo -e "    |---\e[32m[Alterx Done] [Lines: $lines]\e[0m"
  ) &

  (
    # Altdns will permute assetnote wordlist with domain name

    altdns -i "$domain" -w "$wordlistsDir/assetnoteSubdomains.txt" -o altdns.txt
    lines=$(cat altdns.txt | wc -l)
    echo -e "    |---\e[32m[Altdns (Assetnote wordlist) Done] [Lines: $lines]\e[0m"
  ) & 

  wait

  cat dnsgen.txt alterx.txt altdns.txt | sort -u | tee -a totalPermuted.txt 2> /dev/null


  # Puredns will resolve the permuted subdomains 
  puredns resolve "totalPermuted.txt" -q | tee -a activeSubdomains.txt
  lines=$(cat activeSubdomains.txt | wc -l)
  echo -e "    |---\e[32m[Active Enumeration Done] [Active Subdomains: $lines]\e[0m"

  cat activeSubdomains.txt passiveSubdomains.txt | sort -u | tee -a active+passive.txt 2> /dev/null
}

organise() {

cat active+passive.txt | httpx -t 100 -mc 200,201,202,300,301,302,303,400,401,402,403,404 | tee subdomains.txt 
cat subdomains.txt | httpx > liveSubdomains.txt 2> /dev/null

mv "assetfinderSubdomains.txt" "combinedPassiveSubdomains.txt" "subfinderSubdomains.txt" "subdominatorSubdomains.txt" "amassSubdomains.txt" "haktrailsSubdomains.txt" ".tmp/subdomains/passive" 2> /dev/null
mv "dnsgen.txt" "alterx.txt" "altdns.txt" "totalPermuted.txt" ".tmp/subdomains/active" 2> /dev/null
mv "active+passive.txt" ".tmp/subdomains/"

}


if [ "$3" == "passive" ]; then
  passiveEnumeration
  cat passiveSubdomains.txt | sort -u | tee -a active+passive.txt
  organise
elif [ "$3" == "active" ]; then
  if [ -f "passiveSubdomains.txt" ]; then
    activeEnumeration
    organise
  else
    passiveEnumeration
    activeEnumeration
    cat passiveSubdomains.txt activeSubdomains.txt | sort -u | tee -a active+passive.txt
    organise
  fi
elif [ "$3" == "both" ]; then
    passiveEnumeration
    activeEnumeration
    cat passiveSubdomains.txt activeSubdomains.txt | sort -u | tee -a active+passive.txt
    organise
else
  passiveEnumeration
  cat passiveSubdomains.txt | sort -u | tee -a active+passive.txt
  organise
fi


