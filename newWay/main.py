import subprocess
import os
import threading
import requests
        

def subdomains(domain):
    print("[Task: Subdomain Enumeration] [Status: In progress]")
    p_subdomain = subprocess.Popen(f"echo {domain} | ./subdomains.sh",shell=True).wait()
    print("[Task: subdomainEnumeration] [Status: Completed]")


def subTakeover(domain):
    print("[Task: Subdomain Takeover Check] [Status: In progress]")
    p_urls= subprocess.Popen(f"echo {domain} | ./subTakeover.sh",shell=True)


def urls(domain):
    print("[Task: URL Gathering] [Status: In progress]")
    p_urls= subprocess.Popen(f"echo {domain} | ./urls.sh",shell=True)


def check_internet():
    try:
        response = requests.get("https://8.8.8.8", timeout=2)
        return True
    except requests.ConnectionError:
        return False


def main():

    try:

        if check_internet():

            os.system('clear')
            domain = input("Enter the domain name: ")
            print("<---------Go hunt for the bugs, leave recon on me--------->")

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


