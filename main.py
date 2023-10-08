#!/usr/bin/python3

import os
import shutil
import subprocess
import threading
import requests
from colorama import Fore, Back, Style
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-update", action='store_true', help="Update to latest version")
parser.add_argument("-f", help="Give file name consisting of target domains")
parser.add_argument("-all", help="[Subdomain & URL Enum, Subdomain Takeover, SSRF, XSS, Nuclei]: Provide Link for SSRF Testing")
parser.add_argument("-ssrf", help="SSRF Testing: Provide Burp Collaborator/Server link")
parser.add_argument("-xss", action='store_true', help="XSS testing")
parser.add_argument("-sub", action='store_true', help="Subdomain Enumeration")
parser.add_argument("-tkovr", action='store_true', help="Subdomain Takeover check")
parser.add_argument("-urls", action='store_true', help="URL Enumeration")
parser.add_argument("-nuclei", action='store_true', help="Use Nuclei")
parser.add_argument("-amass_t", help="Amass timeout [Default 30 mins] [Use 0 for no timeout] [-amass_t 30 for 30 min timeout ]")
parser.add_argument("-example", action='store_true', help="Example: python3 main.py -f domains.txt -all https://burpcollaborator.link")

args = parser.parse_args()

# Update the Tool
REPO_URL = 'https://github.com/Kirosci/Project-Recon.git'

# For Updating the tool 
def update():
    print(Fore.BLUE + "[+] [Task: Update]", end=' ') 
    print (Fore.YELLOW + "[Status: In progress]", end=' ')
    print(Style.RESET_ALL)
    p_update = subprocess.Popen("bash scripts/update.sh", shell=True).wait()
    print(Fore.BLUE + "[+] [Task: Update]", end=' ') 
    print (Fore.GREEN + "[Status: Completed]", end=' ')
    print(Style.RESET_ALL)

# For gathering subdomains
def subdomains(domain, amass_timeout):
    print(Fore.BLUE + "[+] [Task: Subdomain Enumeration]", end=' ') 
    print (Fore.YELLOW + "[Status: In progress]", end=' ')
    print(Style.RESET_ALL)
    p_subdomain = subprocess.Popen(f"bash scripts/subdomains.sh {domain} {amass_timeout}",shell=True).wait()
    print(Fore.BLUE + "[+] [Task: Subdomain Enumeration]", end=' ') 
    print (Fore.GREEN + "[Status: Completed]", end=' ')
    print (Fore.CYAN + "[Info: Results saved in subdomains.txt & live_subdomains.txt]", end=' ')
    print(Style.RESET_ALL)

# For checking subdomain takeover 
def subTakeover(domain):
    print(Fore.BLUE + "[+] [Task: Subdomain Takeover Check]", end=' ') 
    print (Fore.YELLOW + "[Status: In progress]", end=' ')
    print(Style.RESET_ALL)
    p_urls= subprocess.Popen(f"echo {domain} | bash scripts/subTakeover.sh",shell=True)
    print(Fore.BLUE + "[+] [Task: Subdomain Takeover Check]", end=' ') 
    print (Fore.GREEN + "[Status: Completed]", end=' ')
    print (Fore.CYAN + "[Info: Results saved in subTakeovers.txt]", end=' ')
    print(Style.RESET_ALL)

# For gathering urls 
def urls(domain):
    print(Fore.BLUE + "[+] [Task: URL Gathering]", end=' ') 
    print (Fore.YELLOW + "[Status: In progress]", end=' ')
    print(Style.RESET_ALL)
    p_urls= subprocess.Popen(f"echo {domain} | bash scripts/urls.sh",shell=True).wait()
    print(Fore.BLUE + "[+] [Task: URL Gathering]", end=' ') 
    print (Fore.GREEN + "[Status: Completed]", end=' ')
    print (Fore.CYAN + "[Info: Results saved in urls.txt]", end=' ')
    print(Style.RESET_ALL)

def ssrf(domain, link): 
    print(Fore.BLUE + "[+] [Task: SSRF Testing]", end=' ') 
    print (Fore.YELLOW + "[Status: In progress]", end=' ')
    print(Style.RESET_ALL)
    p_urls= subprocess.Popen(f"bash scripts/ssrf.sh {domain} {link}",shell=True).wait()
    print(Fore.BLUE + "[+] [Task: SSRF Testing]", end=' ') 
    print (Fore.GREEN + "[Status: Completed]", end=' ')
    print (Fore.CYAN + "[Info: Results saved in all_ssrf_urls.txt | Check if you get any pingbacks]", end=' ')
    print(Style.RESET_ALL)

def xss(domain):
    print(Fore.BLUE + "[+] [Task: XSS Testing]", end=' ') 
    print (Fore.YELLOW + "[Status: In progress]", end=' ')
    print(Style.RESET_ALL)
    p_urls= subprocess.Popen(f"echo {domain} | bash scripts/xss.sh",shell=True).wait()
    print(Fore.BLUE + "[+] [Task: XSS Testing]", end=' ') 
    print (Fore.GREEN + "[Status: Completed]", end=' ')
    print (Fore.CYAN + "[Info: Results saved in kxss.txt file]", end=' ')
    print(Style.RESET_ALL)

def nuclei(domain):
    print(Fore.BLUE + "[+] [Task: Nuclei]", end=' ') 
    print (Fore.YELLOW + "[Status: In progress]", end=' ')
    print(Style.RESET_ALL)
    p_urls= subprocess.Popen(f"echo {domain} | bash scripts/nuclei.sh",shell=True).wait()
    print(Fore.BLUE + "[+] [Task: Nuclei]", end=' ') 
    print (Fore.GREEN + "[Status: Completed]", end=' ')
    print (Fore.CYAN + "[Info: Results Saved in nuclei.txt]", end=' ')
    print(Style.RESET_ALL)

# Check internet connection 
def check_internet():
    try:
        response = requests.get("https://8.8.8.8", timeout=2)
        return True
    except requests.ConnectionError:
        return False


def main():
    # Handling sudden termination
    try:
        # Check Internet Connection
        if check_internet():
            # Get Target Domain name
            main_script_directory = os.path.dirname(os.path.abspath(__file__))
            target_directory = os.path.join(main_script_directory, 'Project-Recon')

            if args.update:
                thre_update = threading.Thread(target=update)
                thre_update.start()
                thre_update.join()
            else:
                parser.error(Fore.RED + "\n[+] [-update should be used alone, without other arguments]")
                
                

            if args.f:
                domain = args.f
                print(Back.WHITE, Fore.RED + '[~Automating the hunt, so I can hunt more and sleep less]', Style.RESET_ALL)

            else:
                print(Fore.RED + "[Status: File name not provided]", end=' ') 
                print(Fore.BLUE + "[Info: Please provide a file name consisting of target domains]") 

            if args.amass_t:
                amass_timeout = args.amass_t
            else:
                amass_timeout = 30

            if args.all:

                # Subdomain Enumeration Start AND WAIT 
                thread_subdomains = threading.Thread(target=subdomains, args=(domain,amass_timeout,))
                thread_subdomains.start()
                thread_subdomains.join()
                
                # Subdomain Takeover
                thread_subTakeover = threading.Thread(target=subTakeover, args=(domain,))
                thread_subTakeover.start()

                # URL Enumeration Start AND WAIT
                thread_urls = threading.Thread(target=urls, args=(domain,))
                thread_urls.start()
                thread_urls.join()

                # SSRF Testing
                link = args.all
                thread_ssrf = threading.Thread(target=ssrf, args=(domain, link,))
                thread_ssrf.start()

                # Nuclei Scan
                thread_nuclei = threading.Thread(target=nuclei, args=(domain,))
                thread_nuclei.start()

                # XSS Testing 
                thread_xss = threading.Thread(target=xss, args=(domain,))
                thread_xss.start()



            else:

                # Subdomain Enumeration thread start AND WAIT
                if args.sub:
                    thread_subdomains = threading.Thread(target=subdomains, args=(domain,amass_timeout,))
                    thread_subdomains.start()
                    thread_subdomains.join()
                else:
                    print(Fore.RED + "[+] [Task: Subdomain Enumeration]", end=' ') 
                    print (Fore.BLUE + "[Status: Argument Not Provided]")
 
                # Subdomain Takeover thread start 
                if args.tkovr:
                    thread_subTakeover = threading.Thread(target=subTakeover, args=(domain,))
                    thread_subTakeover.start()
                else:
                    print(Fore.RED + "[+] [Task: Subdomain Takeover]", end=' ') 
                    print (Fore.BLUE + "[Status: Argument Not Provided]")
 
                # URL Enumeration thread start AND WAIT
                if args.urls:
                    thread_urls = threading.Thread(target=urls, args=(domain,))
                    thread_urls.start()
                    thread_urls.join()
                else:
                    print(Fore.RED + "[+] [Task: URL Enumeration]", end=' ') 
                    print (Fore.BLUE + "[Status: Argument Not Provided]")

                # SSRF testing thread start
                if args.ssrf:
                    link = args.ssrf
                    thread_ssrf = threading.Thread(target=ssrf, args=(domain, link,))
                    thread_ssrf.start()
                else:
                    print(Fore.RED + "[+] [Task: SSRF Testing]", end=' ') 
                    print (Fore.BLUE + "[Status: Argument Not Provided]")

                # Nuclei Scan thread start
                if args.nuclei:
                    thread_nuclei = threading.Thread(target=nuclei, args=(domain,))
                    thread_nuclei.start()
                else:
                    print(Fore.RED + "[+] [Task: Nuclei Scan]", end=' ') 
                    print (Fore.BLUE + "[Status: Argument Not Provided]")

                # XSS testing thread start
                if args.xss:
                    thread_xss = threading.Thread(target=xss, args=(domain,))
                    thread_xss.start()
                else:
                    print(Fore.RED + "[+] [Task: XSS Testing]", end=' ') 
                    print (Fore.BLUE + "[Status: Argument Not Provided]")

        else:
            print("Internet is not working!")

    except KeyboardInterrupt:
        print("\n[Terminated: You pressed ctrl+c]")


if __name__ == '__main__':
    main()