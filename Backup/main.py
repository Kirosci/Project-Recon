import subprocess
import os
import threading
import requests
from colorama import Fore, Back, Style
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-ssrf", help="Please give your Burp Collaborator link/Server link")
parser.add_argument("-xss", action='store_true', help="If you want to perform XSS testing")
args = parser.parse_args()

# For gathering subdomains
def subdomains(domain):
    print(Fore.BLUE + "[Task: Subdomain Enumeration]", end=' ') 
    print (Fore.GREEN + "[Status: In progress]")
    print(Fore.WHITE + "    |---[Assetfinder |  Subfinder | Amass | Haktrails]")
    print(Style.RESET_ALL)
    p_subdomain = subprocess.Popen(f"echo {domain} | ./subdomains.sh",shell=True).wait()
    print(Fore.BLUE + "[Task: Subdomain Enumeration]", end=' ') 
    print (Fore.GREEN + "[Status: Completed]")
    print(Style.RESET_ALL)

# For checking subdomain takeover 
def subTakeover(domain):
    print(Fore.BLUE + "[Task: Subdomain Takeover Check]", end=' ') 
    print (Fore.GREEN + "[Status: In progress]")
    print(Fore.WHITE + "    |---[Dig]")
    print(Style.RESET_ALL)
    p_urls= subprocess.Popen(f"echo {domain} | ./subTakeover.sh",shell=True)
    print(Fore.BLUE + "[Task: Subdomain Takeover Check]", end=' ') 
    print (Fore.GREEN + "[Status: Completed]")
    print(Style.RESET_ALL)

# For gathering urls 
def urls(domain):
    print(Fore.BLUE + "[Task: URL Gathering]", end=' ') 
    print (Fore.GREEN + "[Status: In progress]")
    print(Fore.WHITE + "    |---[Waybackurls | GAU | Katana]")
    print(Style.RESET_ALL)
    p_urls= subprocess.Popen(f"echo {domain} | ./urls.sh",shell=True).wait()
    print(Fore.BLUE + "[Task: URL Gathering]", end=' ') 
    print (Fore.GREEN + "[Status: Completed]")
    print(Style.RESET_ALL)

def ssrf(domain, link): 
    print(Fore.BLUE + "[Task: SSRF Testing]", end=' ') 
    print (Fore.GREEN + "[Status: In progress]")
    print(Fore.WHITE + "    |---[Qsreplace]")
    print(Style.RESET_ALL)
    p_urls= subprocess.Popen(f"./ssrf.sh {domain} {link}",shell=True).wait()
    print(Fore.BLUE + "[Task: SSRF Testing]", end=' ') 
    print (Fore.GREEN + "[Status: Completed]")
    print (Fore.CYAN + "[Info: Check if you get any pingbacks]")
    print(Style.RESET_ALL)

def xss(domain):
    print(Fore.BLUE + "[Task: XSS Testing]", end=' ') 
    print (Fore.GREEN + "[Status: In progress]")
    print(Fore.WHITE + "    |---[KXSS]")
    print(Style.RESET_ALL)
    p_urls= subprocess.Popen(f"./xss.sh {domain}",shell=True).wait()
    print(Fore.BLUE + "[Task: XSS Testing]", end=' ') 
    print (Fore.GREEN + "[Status: Completed]")
    print (Fore.CYAN + "[Info: Check *kxss.txt* file]")
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

            os.system('clear')
            # Get Target Domain name 
            domain = input(Fore.WHITE + "Enter the domain name: ")

            print(Fore.YELLOW + "<---------Go hunt for the bugs, leave recon on me--------->")

            # Making threads for functions
            thread_subdomains = threading.Thread(target=subdomains, args=(domain,))
            thread_urls = threading.Thread(target=urls, args=(domain,))
            thread_subTakeover = threading.Thread(target=subTakeover, args=(domain,))

            # Calling first function [subdomainEnumeration()] 
            thread_subdomains.start()
            thread_subdomains.join()
            # When first function get finished these will be called parallelly
            thread_subTakeover.start()
            thread_urls.start()
            thread_urls.join()
            
            # SSRF testing thread start
            if args.ssrf:
                link = ("%s" % args.ssrf)
                thread_ssrf = threading.Thread(target=ssrf, args=(domain,link,))
                thread_ssrf.start()
            else:
                print(Fore.RED + "[Task: SSRF Testing]", end=" ")
                print(Fore.BLUE + "[Info:Something went wrong]")
            
            # XSS testing thread start 
            if args.xss:
                thread_xss = threading.Thread(target=xss, args=(domain,))
                thread_xss.start()
            else:
                print(Fore.RED + "[Task: XSS Testing]", end=" ")
                print(Fore.BLUE + "[Info:Something went wrong]") 

        else:
            print("Internet is not working!")

    except KeyboardInterrupt:
        print("\n[Terminated: You pressed ctrl+c]")


if __name__ == '__main__':
    
    main()