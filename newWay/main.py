import subprocess
import os
import threading
import requests
import colorama
        
# For gathering subdomains
def subdomains(domain):
    print(Fore.BLUE + "[Task: Subdomain Enumeration]", end=' ') 
    print (Fore.GREEN + "[Status: In progress]")
    print(Style.RESET_ALL)
    print("    |---[Assetfinder |  Subfinder | Amass | Haktrails]")
    p_subdomain = subprocess.Popen(f"echo {domain} | ./subdomains.sh",shell=True).wait()
    print(Fore.BLUE + "[Task: Subdomain Enumeration]", end=' ') 
    print (Fore.GREEN + "[Status: Completed]")
    print(Style.RESET_ALL)

# For checking subdomain takeover 
def subTakeover(domain):
    print(Fore.BLUE + "[Task: Subdomain Takeover Check]", end=' ') 
    print (Fore.GREEN + "[Status: In progress]")
    print(Style.RESET_ALL)
    print("    |---[Dig]")
    p_urls= subprocess.Popen(f"echo {domain} | ./subTakeover.sh",shell=True)
    print(Fore.BLUE + "[Task: Subdomain Takeover Check]", end=' ') 
    print (Fore.GREEN + "[Status: Completed]")
    print(Style.RESET_ALL)

# For gathering urls 
def urls(domain):
    print(Fore.BLUE + "[Task: URL Gathering]", end=' ') 
    print (Fore.GREEN + "[Status: In progress]")
    print(Style.RESET_ALL)
    print("    |---[Waybackurls | GAU | Katana]")
    p_urls= subprocess.Popen(f"echo {domain} | ./urls.sh",shell=True)
    print(Fore.BLUE + "[Task: URL Gathering]", end=' ') 
    print (Fore.GREEN + "[Status: Completed]")
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
            domain = input("Enter the domain name: ")

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

        else:
            print("Internet is not working!")

    except KeyboardInterrupt:
        print("\n[Terminated: You pressed ctrl+c]")


if __name__ == '__main__':
    
    main()


