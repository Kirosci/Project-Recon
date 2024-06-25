#!/bin/bash


if [[ -z "$2" ]]; then
    timeout="$2"
else
    timeout="0"
fi

GREEN="\e[32m"
RED="\e[31m"
ORANGE="\e[38;5;214m"
RESET="\e[0m"


domainFile=$1

baseDir="$(pwd)"

# ---

passiveEnumeration(){

(
  echo "$domain" | assetfinder >> assetfinderSubdomains.txt
  lines=$(cat assetfinderSubdomains.txt | wc -l)
  echo -e "\t\t|---${GREEN}[Assetfinder: $lines]${RESET}"
) &
(
  echo "$domain" | haktrails subdomains >> haktrailsSubdomains.txt
  lines=$(cat haktrailsSubdomains.txt | wc -l)
  echo -e "\t\t|---${GREEN}[Haktrails: $lines]${RESET}"
) &
(
  echo "$domain" | subfinder -o subfinderSubdomains.txt 2> /dev/null 1> /dev/null
  lines=$(cat subfinderSubdomains.txt | wc -l)
  echo -e "\t\t|---${GREEN}[Subfinder: $lines]${RESET}"
) &
(
  subdominator -d "$domain" -o subdominatorSubdomains.txt 2> /dev/null 1> /dev/null & wait
  lines=$(cat subdominatorSubdomains.txt | wc -l)
  echo -e "\t\t|---${GREEN}[Subdominator: $lines]${RESET}" 
) &

(
  if [[ "$2" -eq 1 ]]; then

    amass enum -d "$domain" -o amassSubdomains.txt 2> /dev/null 1> /dev/null
    lines=$(cat amassSubdomains.txt | wc -l)
    echo -e "\t\t|---${GREEN}[Amass: $lines]${RESET}"

  elif [[ "$2" -eq 0 ]]; then

  echo -e "\t\t|---${RED}[Excluded Amass]${RESET}" 

  else

    amass enum -d "$domain" -timeout $timeout -o amassSubdomains.txt 2> /dev/null
    lines=$(cat amassSubdomains.txt | wc -l)
    echo -e "\t\t|---${GREEN}[Amass: $lines] [Timeout: $2 minutes]${RESET}" 

  fi
) &

wait
#----------------------------Sorting Assets-----------------------------------------
cat assetfinderSubdomains.txt subdominatorSubdomains.txt amassSubdomains.txt haktrailsSubdomains.txt subfinderSubdomains.txt 2> /dev/null | sort -u >> combinedPassiveSubdomains.txt
# Filtering out false positives
grep -E "\\b${domain//./\\.}\\b" "combinedPassiveSubdomains.txt" | awk '{print$1}' | sort -u >> "passiveSubdomains.txt"
cat activeSubdomains.txt passiveSubdomains.txt 2> /dev/null | sort -u > active+passive.txt 2> /dev/null

}

# ---

checkWordlist() {

  # Getting wordlist name to know it's last updated date
  wordlistDate=$(ls $wordlistsDir | grep httparchive_subdomains | sed -e 's/httparchive_subdomains_//' -e 's/.txt//')
  currentDate=$(date +%Y_%m_%d)
  # Convert the dates to the format YYYYMMDD for comparison
  wordlistDate_converted=$(date -d "${wordlistDate//_/}" +%Y%m%d)
  currentDate_converted=$(date -d "${currentDate//_/}" +%Y%m%d)

# Downloading '2m-subdomains.txt' wordlist if not there
  cd $wordlistsDir
  if ! [ -f "2m-subdomains.txt" ]; then
  wget "https://wordlists-cdn.assetnote.io/data/manual/2m-subdomains.txt" 1> /dev/null
  fi
  cd $dir

# Downloading in http_archive wordlist is not there
  cd $wordlistsDir
  wordlistName=$(ls | grep httparchive_subdomains_)

  if ! [ -f $wordlistName ]; then
    wget "https://wordlists-cdn.assetnote.io/data/automated/httparchive_subdomains_$(date +%Y)_$(date +%m)_28.txt" 1> /dev/null
    rm assetnoteSubdomains.txt 2> /dev/null
    cat "httparchive_subdomains_$(date +%Y)_$(date +%m)_28.txt" "2m-subdomains.txt" | sort -u > assetnoteSubdomains.txt 
  else
    # Updating http_archive wordlist if exists
    if [ "$wordlistDate_converted" -lt "$currentDate_converted" ]; then
      if [ $(date +%d) -gt 27 ]; then
        # Updating the wordlist, If last updated date of wordlist is earlier than current date and if current date is greatter than 27
        rm httparchive_subdomains_*
        wget "https://wordlists-cdn.assetnote.io/data/automated/httparchive_subdomains_$(date +%Y)_$(date +%m)_28.txt" 1> /dev/null
        rm assetnoteSubdomains.txt 2> /dev/null
        cat "httparchive_subdomains_$(date +%Y)_$(date +%m)_28.txt" "2m-subdomains.txt" | sort -u | tee -a assetnoteSubdomains.txt
      fi
    fi
  fi
  cd $dir

# Generating 'assetnoteSubdomains' wordlist if not there
  cd $wordlistsDir
  if ! [ -f "assetnoteSubdomains.txt" ]; then
  cat httparchive_subdomains_* 2m-subdomains.txt | sort -u > assetnoteSubdomains.txt
  fi
  cd $dir

}

# ---

activeEnumeration() { 
  # (
  #   # Dnsgen will take list of subdomains (passiveSubdomains.txt) and will permute between them
  #   dnsgen "passiveSubdomains.txt" -f | tee -a dnsgen.txt
  #   lines=$(cat dnsgen.txt | wc -l)
  #   echo -e "\t\t|---${GREEN}[Dnsgen: $lines]${RESET}"
  # ) &
  (
    # Alterx takes subdomains (passiveSubdomains.txt) and will permute between them, on behalf of specified rules
    cat "passiveSubdomains.txt" | alterx -o alterx.txt 2> /dev/null
    lines=$(cat alterx.txt | wc -l)
    echo -e "\t\t|---${GREEN}[Alterx: $lines]${RESET}"
  ) &
  # (
  #   # Altdns will permute assetnote wordlist with domain name
  #   altdns -i "$domain" -w "$wordlistsDir/assetnoteSubdomains.txt" -o altdns.txt
  #   lines=$(cat altdns.txt | wc -l)
  #   echo -e "\t\t|---${GREEN}[Altdns (Assetnote wordlist): $lines]${RESET}"
  # ) & 
  wait

  cat dnsgen.txt alterx.txt altdns.txt 2> /dev/null | sort -u > totalPermuted.txt 

  # Puredns will resolve the permuted subdomains 
  puredns resolve "totalPermuted.txt" -q > tee -a activeSubdomains.txt
  lines=$(cat activeSubdomains.txt | wc -l)
  echo -e "\t\t|---${GREEN}[Active Enumeration Done] [Active Subdomains: $lines]${RESET}"
  cat activeSubdomains.txt passiveSubdomains.txt | sort -u > active+passive.txt

}

# ---

organise() {
cat active+passive.txt | httpx -t 100 -mc 200,201,202,300,301,302,303,400,401,402,403,404 -o subdomains.txt 2> /dev/null 1> /dev/null
cat subdomains.txt | httpx -o liveSubdomains.txt 2> /dev/null 1> /dev/null
mv "assetfinderSubdomains.txt" "combinedPassiveSubdomains.txt" "subfinderSubdomains.txt" "subdominatorSubdomains.txt" "amassSubdomains.txt" "haktrailsSubdomains.txt" "passiveSubdomains.txt " ".tmp/subdomains/passive" 2> /dev/null
mv "dnsgen.txt" "alterx.txt" "altdns.txt" "totalPermuted.txt" "activeSubdomains.txt" ".tmp/subdomains/active" 2> /dev/null
mv "active+passive.txt" ".tmp/subdomains/" 2> /dev/null
}

# ---

screenshot() {
  nuclei -l subdomains.txt -headless -t ~/nuclei-templates/headless/screenshot.yaml -c 100 2> /dev/null 1> /dev/null
}

# ---

while IFS= read -r domain; do

  dir="results/$domain"
  mkdir -p "$dir" 
  cd $dir

  echo -e "\t${ORANGE}[$domain]${RESET}"
  
  mkdir -p .tmp/subdomains
  mkdir -p .tmp/subdomains/passive
  mkdir -p .tmp/subdomains/active
  mkdir -p screenshots

  rm subdomains.txt 2> /dev/null
  rm liveSubdomains.txt 2> /dev/null

  wordlistsDir="$(pwd)/wordlists"


  if [ "$3" == "passive" ]; then
    passiveEnumeration
    cat passiveSubdomains.txt | sort -u > active+passive.txt
    screenshot
    organise
  elif [ "$3" == "active" ]; then
    if [ -f "passiveSubdomains.txt" ]; then
      checkWordlist
      activeEnumeration
      screenshot
      organise
    else
      passiveEnumeration
      checkWordlist
      activeEnumeration
      cat passiveSubdomains.txt activeSubdomains.txt | sort -u > active+passive.txt
      screenshot
      organise
    fi
  elif [ "$3" == "both" ]; then
      passiveEnumeration
      checkWordlist
      activeEnumeration
      cat passiveSubdomains.txt activeSubdomains.txt | sort -u > active+passive.txt
      screenshot
      organise
  else
    passiveEnumeration
    cat passiveSubdomains.txt | sort -u > active+passive.txt
    screenshot
    organise
  fi

  echo -e "\t${GREEN}[Found: $(wc -l subdomains.txt | awk '{print$1}')]${RESET}"
  
# Go back to Project-Recon dir at last 
  cd $baseDir
done < $domainFile
