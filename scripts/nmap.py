from tld import get_tld
import sys
import requests
from bs4 import BeautifulSoup
import os
import subprocess

bgpUrl = "https://bgp.he.net/search?search%5Bsearch%5D="

def getAsn(file):
    with open(file, 'r') as file:
        for url in file:
            os.chdir(f'results/{url.strip()}')
            url = url.strip()  # Remove any leading/trailing whitespace
            dir_name = f'results/{url}'
            
            url = "https://" + url
            urlObj = get_tld(url, as_object=True)
            print(f"Domain: {urlObj.domain}")
            print(f"Requesting to {bgpUrl}{urlObj.domain}")
            
            response = requests.get(f"{bgpUrl}{urlObj.domain}")
            response.raise_for_status()

            soup = BeautifulSoup(response.text, 'html.parser')

            # Find all ASN tags
            asns = soup.find_all('a', href=True)
            asnNumbers = []

            # Extract the ASN numbers
            for asn in asns:
                href = asn['href']
                if href.startswith('/AS'):
                    asnNumber = href.split('/')[1]
                    asnNumbers.append(asnNumber)

            # Write the ASN numbers to a file in the corresponding directory
            with open('asn.txt', 'w') as asnFile:
                for number in asnNumbers:
                    print(f"ASN Number for {urlObj.domain}: {number}")
                    asnFile.write(f"{number}\n")
            # Going two directories back to get Project-Recon directory path, currently it is in 'results/$domain'
            asnIpFilePath = f"{os.path.dirname(os.path.dirname(os.getcwd()))}/scripts"
            cmd = f"cat asn.txt | bash {asnIpFilePath}/nmap.sh"
            subprocess.Popen(cmd,shell=True).wait()

                

if __name__ == "__main__":
    getAsn(sys.argv[1])
   

