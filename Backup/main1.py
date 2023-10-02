import subprocess
import os
import threading
import requests
from colorama import Fore, Back, Style
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-f", help="Give file name consisting of target domains")
parser.add_argument("-all", help="[Subdomain & URL Enum, Subdomain Takeover, SSRF, XSS, Nuclei]: Provide Link for SSRF Testing")
parser.add_argument("-ssrf", help="SSRF Testing: Provide Burp Collaborator/Server link")
parser.add_argument("-xss", action='store_true', help="XSS testing")
parser.add_argument("-sub", action='store_true', help="Subdomain Enumeration")
parser.add_argument("-tkovr", action='store_true', help="Subdomain Takeover check")
parser.add_argument("-urls", action='store_true', help="URL Enumeration")
parser.add_argument("-nuclei", action='store_true', help="Use Nuclei")

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
    p_urls= subprocess.Popen(f"echo {domain} | ./xss.sh",shell=True).wait()
    print(Fore.BLUE + "[Task: XSS Testing]", end=' ') 
    print (Fore.GREEN + "[Status: Completed]")
    print (Fore.CYAN + "[Info: Check *kxss.txt* file]")
    print(Style.RESET_ALL)

def nuclei(domain):
    print(Fore.BLUE + "[Task: Nuclei]", end=' ') 
    print (Fore.GREEN + "[Status: In progress]")
    print(Fore.WHITE + "    |---[Nuclei]")
    print(Style.RESET_ALL)
    p_urls= subprocess.Popen(f"echo {domain} | ./nuclei.sh",shell=True).wait()
    print(Fore.BLUE + "[Task: Nuclei]", end=' ') 
    print (Fore.GREEN + "[Status: Completed]")
    print (Fore.CYAN + "[Info: Results Saved in nuclei.txt]")
    print(Style.RESET_ALL)

# Check internet connection 
def check_internet():
    try:
        response = requests.get("https://8.8.8.8", timeout=2)
        return True
    except requests.ConnectionError:
        return False


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-all', action='store_true', help='Execute all tasks sequentially')
    parser.add_argument('-sub', action='store_true', help='Execute subdomains task')
    parser.add_argument('-tkovr', action='store_true', help='Execute subTakeover task')
    parser.add_argument('-urls', action='store_true', help='Execute URLs task')
    parser.add_argument('-ssrf', type=str, help='Execute SSRF task')
    parser.add_argument('-xss', action='store_true', help='Execute XSS task')
    args = parser.parse_args()

    # Handling sudden termination
    try:
        # Check Internet Connection
        if check_internet():
            # Get Target Domain name

            if args.f:
                domain = args.f
                print("<---------Go hunt for the bugs, leave recon on me--------->")
            else:
                print("[Info: File name not provided]")
                print("[Please provide a file name consisting of target domains]")

            if args.all:
                thread_subdomains = threading.Thread(target=subdomains, args=(domain,))
                thread_subdomains.start()
                thread_subdomains.join()

                thread_subTakeover = threading.Thread(target=subTakeover, args=(domain,))
                thread_subTakeover.start()
                thread_subTakeover.join()

                thread_urls = threading.Thread(target=urls, args=(domain,))
                thread_urls.start()
                thread_urls.join()

                link = args.ssrf
                thread_ssrf = threading.Thread(target=ssrf, args=(domain, link,))
                thread_ssrf.start()

                thread_xss = threading.Thread(target=xss, args=(domain,))
                thread_xss.start()

                thread_subdomains.join()
                thread_subTakeover.join()
                thread_urls.join()
                thread_ssrf.join()
                thread_xss.join()

                thread_nuclei = threading.Thread(target=nuclei, args=(domain,))
                thread_nuclei.start()
                thread_nuclei.join()

            else:
                # Subdomain Enumeration thread start
                if args.sub:
                    thread_subdomains = threading.Thread(target=subdomains, args=(domain,))
                    thread_subdomains.start()
                    thread_subdomains.join()
                else:
                    print("[Task: Subdomain Enumeration] [Argument not provided]")

                # Subdomain Takeover thread start
                if args.tkovr:
                    thread_subTakeover = threading.Thread(target=subTakeover, args=(domain,))
                    thread_subTakeover.start()
                    thread_subTakeover.join()
                else:
                    print("[Task: Subdomain Takeover] [Argument not provided]")

                # URL Enumeration thread start
                if args.urls:
                    thread_urls = threading.Thread(target=urls, args=(domain,))
                    thread_urls.start()
                    thread_urls.join()
                else:
                    print("[Task: URL Enumeration] [Argument not provided]")

                # SSRF testing thread start
                if args.ssrf:
                    link = args.ssrf
                    thread_ssrf = threading.Thread(target=ssrf, args=(domain, link,))
                    thread_ssrf.start()
                else:
                    print("[Task: SSRF Testing] [Argument not provided]")

                # XSS testing thread start
                if args.xss:
                    thread_xss = threading.Thread(target=xss, args=(domain,))
                    thread_xss.start()
                else:
                    print("[Task: XSS Testing] [Argument not provided]")

                thread_nuclei = threading.Thread(target=nuclei, args=(domain,))
                thread_nuclei.start()
                thread_nuclei.join()

        else:
            print("Internet is not working!")

    except KeyboardInterrupt:
        print("\n[Terminated: You pressed ctrl+c]")


if __name__ == '__main__':
    main()