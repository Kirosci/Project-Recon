#!/usr/bin/python3
import sys
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
parser.add_argument("-tkovr", action='store_true', help="Subdomain Takeover check")
parser.add_argument("-nuclei", action='store_true', help="Use Nuclei")
parser.add_argument("-fuzz", action='store_true', help="Fuzz for endpoints")
parser.add_argument("-js", action='store_true', help="Analyse JS files for juicy stuff")

parser.add_argument("-urls", nargs='?', const='ps', help="URL Enumeration, ac: for crawling, ps: for passive gathering, provide no value for both")
parser.add_argument("-sub", nargs='?', const='ps', help="Enumerating Subdomains, ac: for active, ps: for passive, provide no value for both")

parser.add_argument("-nmap", action='store_true', help="Nmap Scan")
parser.add_argument("-amass_t", help="Amass timeout [Default 30 mins] [Use 0 for no timeout] [-amass_t 30 for 30 min timeout ]")
parser.add_argument("-example", action='store_true', help="Example: python3 main.py -f domains.txt -all https://burpcollaborator.link")

args = parser.parse_args()

# github repo to update
REPO_URL = 'https://github.com/Kirosci/Project-Recon.git'


def messageBefore(task):
    print(Fore.BLUE + f"[+] [Task: {task}]", end=' ') 
    print (Fore.YELLOW + "[Status: In progress]", end=' ')
    print(Style.RESET_ALL)

def messageAfter(task, info):
    print(Fore.BLUE + f"[+] [Task: {task}]", end=' ') 
    print (Fore.GREEN + "[Status: Completed]", end=' ')
    print (Fore.CYAN + f"[Info: {info}]", end=' ')
    print(Style.RESET_ALL)

def notProvided(task):
    print(Fore.RED + f"[+] [Task: {task}]", end=' ') 
    print (Fore.BLUE + "[Status: Argument Not Provided]")
    print(Style.RESET_ALL)

def errorMessage(msg):
    print(Fore.RED + f"[+] [Error]", end=' ') 
    print (Fore.BLUE + f"[+] [Info: {msg}]")
    print(Style.RESET_ALL)



# For Updating the tool 
def update(cmd):
    messageBefore("Update")
    p_update = subprocess.Popen(cmd, shell=True).wait()
    messageAfter("Update", "Updated Project-Recon")

# For gathering subdomains
def subdomains(cmd):
    messageBefore("Subdomain Enumeration")
    p_subdomain = subprocess.Popen(cmd,shell=True).wait()
    messageAfter("Subdomain Enumeration", "Results saved in subdomains.txt & liveSubdomains.txt")


# For checking subdomain takeover 
def subTakeover(cmd):
    messageBefore("Subdomain Takeover")
    p_urls= subprocess.Popen(cmd, shell=True).wait()
    messageAfter("Subdomain Takeover", "Results saved in subTakeovers.txt")

# For gathering urls 
def urls(cmd):
    messageBefore("URL Gathering")
    p_urls= subprocess.Popen(cmd,shell=True).wait()
    messageAfter("URL Gathering", "Results saved in urls.txt")

# Sanning SSRF
def ssrf(cmd): 
    messageBefore("SSRF")
    p_urls= subprocess.Popen(cmd,shell=True).wait()
    messageAfter("SSRF", "Results saved in all_ssrf_urls.txt | Check if you get any pingbacks")

# Scanning SSRF
def xss(cmd):
    messageBefore("XSS")
    p_urls= subprocess.Popen(cmd,shell=True).wait()
    messageAfter("XSS", "Results saved in kxss.txt")

# Nuclei
def nuclei(cmd):
    messageBefore("Nuceli")
    p_urls= subprocess.Popen(cmd,shell=True).wait()
    messageAfter("Nuceli", "Results Saved in nuclei.txt")

# Fuzzing
def fuzz(cmd):
    messageBefore("Fuzzing")
    p_urls= subprocess.Popen(cmd,shell=True).wait()
    messageAfter("Fuzzing", "Results Saved in fuzz.txt and fuzz/")

# JS
def js(cmd):
    messageBefore("JS")
    p_urls= subprocess.Popen(cmd,shell=True).wait()
    messageAfter("JS", "Results Saved in js/")

# Nmap
def nmap(cmd):
    messageBefore("Nmap")
    p_urls= subprocess.Popen(cmd,shell=True).wait()
    messageAfter("Nmap", "Results Saved")

# Check internet connection 
def check_internet():
    try:
        response = requests.get("https://8.8.8.8", timeout=2)
        return True
    except requests.ConnectionError:
        return False




def pseudoMain():
        # Handling sudden termination
    try:
        # Check Internet Connection
        if check_internet():
            # Get Target Domain name
            main_script_directory = os.path.dirname(os.path.abspath(__file__))
            target_directory = os.path.join(main_script_directory, 'Project-Recon')


            if args.update:
                cmdUpdate = "bash scripts/update.sh"
                thre_update = threading.Thread(target=update, args=(cmdUpdate,))
                thre_update.start()
                thre_update.join()
            else:
                pass
                

            if args.f:
                domain = args.f
                print(Back.WHITE, Fore.RED + '[Automating to hunt more and sleep less]', Style.RESET_ALL)

            else:
                errorMessage("Provide a file containing domains")
                sys.exit(1) 

            link = args.ssrf
            if args.amass_t:
                amassTimeout = args.amass_t
            else:
                amassTimeout = 30



            if args.sub == 'ac':
                cmdSubdomains = f"bash scripts/subdomains.sh {domain} {amassTimeout} active"
            elif args.sub == 'ps': 
                cmdSubdomains = f"bash scripts/subdomains.sh {domain} {amassTimeout} passive"
            elif args.sub == 'both':
                cmdSubdomains = f"bash scripts/subdomains.sh {domain} {amassTimeout} both"
            elif args.sub == None:
                cmdSubdomains = f"bash scripts/subdomains.sh {domain} {amassTimeout} passive"
            else:
                errorMessage(f"`{args.sub}` is not supported by -sub flag")
                errorMessage("Pass`ac` for active | `ps` for passive | `both` for both active & passive with `-sub` flag")
                sys.exit(1)


            if args.urls == 'ac':
                cmdUrls = f"bash scripts/urls.sh {domain} active"
            elif args.urls == 'ps': 
                cmdUrls = f"bash scripts/urls.sh {domain} passive"
            elif args.urls == 'both':
                cmdUrls = f"bash scripts/urls.sh {domain} both"
            elif args.urls == None:
                cmdUrls = f"bash scripts/urls.sh {domain} passive"
            else:
                errorMessage(f"`{args.urls}` is not supported by -urls flag")
                errorMessage("Pass`ac` for active | `ps` for passive | `both` for both active & passive with `-urls` flag")
                sys.exit(1)



            cmdSubTakeover = f"bash scripts/subTakeover.sh {domain}"
            cmdSsrf = f"bash scripts/ssrf.sh {domain} {link}"
            cmdXss = f"bash scripts/xss.sh {domain}"
            cmdNuclei = f"bash scripts/nuclei.sh {domain}"
            cmdFuzz = f"bash scripts/fuzz.sh {domain}"
            cmdJs = f"bash scripts/js.sh {domain}"
            cmdNmap = f"bash scripts/nmap.sh {domain}"


            if args.all:
                
                # Enumerating Subdomains Start AND WAIT 
                thread_subdomains = threading.Thread(target=subdomains, args=(cmdSubdomains,))
                thread_subdomains.start()
                thread_subdomains.join()

                #Fuzzing subdomains
                thread_fuzz = threading.Thread(target=fuzz, args=(domain,))
                thread_fuzz.start()
                
                # Scanning for potential Subdomain Takeovers
                thread_subTakeover = threading.Thread(target=subTakeover, args=(cmdSubTakeover,))
                thread_subTakeover.start()

                # URL Enumeration Start AND WAIT
                thread_urls = threading.Thread(target=urls, args=(cmdUrls,))
                thread_urls.start()
                thread_urls.join()

                # Scanning for potential SSRF
                link = args.all
                thread_ssrf = threading.Thread(target=ssrf, args=(cmdSsrf,))
                thread_ssrf.start()

                # Running Nuclei
                thread_nuclei = threading.Thread(target=nuclei, args=(cmdNuclei,))
                thread_nuclei.start()

                # Scanning for potential XSS 
                thread_xss = threading.Thread(target=xss, args=(cmdXss,))
                thread_xss.start()

                #Analyzing JS files
                thread_js = threading.Thread(target=js, args=(cmdJs,))
                thread_js.start()

                #Nmap
                thread_nmap = threading.Thread(target=nmap, args=(cmdNmap,))
                thread_nmap.start()



            else:

        # Commented else for each argument, it was looking too chaotic and messy

                # Enumerating Subdomains thread start AND WAIT
                if args.sub:
                    thread_subdomains = threading.Thread(target=subdomains, args=(cmdSubdomains,))
                    thread_subdomains.start()
                    thread_subdomains.join()
                # else:
                #     notProvided("Subdomains Enumeration")


                # Fuzzing subdomains
                if args.fuzz:
                    thread_fuzz = threading.Thread(target=fuzz, args=(cmdFuzz,))
                    thread_fuzz.start()
                # else:
                #     notProvided("Fuzzing")

 
                # Subdomain Takeover thread start 
                if args.tkovr:
                    thread_subTakeover = threading.Thread(target=subTakeover, args=(cmdSubTakeover,))
                    thread_subTakeover.start()
                # else:
                #     notProvided("Subdomain Takeover")

 
                # URL Enumeration thread start AND WAIT
                if args.urls:
                    thread_urls = threading.Thread(target=urls, args=(cmdUrls,))
                    thread_urls.start()
                    thread_urls.join()
                # else:
                #     notProvided("URL Gathering")


                # SSRF testing thread start
                if args.ssrf:
                    link = args.ssrf
                    thread_ssrf = threading.Thread(target=ssrf, args=(cmdSsrf,))
                    thread_ssrf.start()
                # else:
                #     notProvided("SSRF")


                # Nuclei Scan thread start
                if args.nuclei:
                    thread_nuclei = threading.Thread(target=nuclei, args=(cmdNuclei,))
                    thread_nuclei.start()
                # else:
                #     notProvided("Nuclei")


                # XSS testing thread start
                if args.xss:
                    thread_xss = threading.Thread(target=xss, args=(cmdXss,))
                    thread_xss.start()
                # else:
                #     notProvided("XSS")


                # JS analyzing thread start
                if args.js:
                    thread_js = threading.Thread(target=js, args=(cmdJs,))
                    thread_js.start()
                # else:
                #     notProvided("JS")

                
                #Nmap
                if args.nmap:
                    thread_nmap = threading.Thread(target=nmap, args=(cmdNmap,))
                    thread_nmap.start()
                # else:
                #     notProvided("JS")



        else:
            print("Internet is not working!")

    except KeyboardInterrupt:
        print("\n[Terminated: You pressed ctrl+c]")



def main():

    pseudoMain()

if __name__ == '__main__':
    main()