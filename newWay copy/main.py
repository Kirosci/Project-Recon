import subprocess
import os
import threading
domain = input("Enter the domain name: ")

def subdomains():
    print("[Task: Subdomain Enumeration] [Status: Sent to Queue]")
    p_subdomain = subprocess.Popen(f"echo {domain} | ./subdomains.sh",shell=True).wait()
    print("[Task: subdomainEnumeration] [Status: Completed]")


def subTakeover():
    print("[Task: Subdomain Takeover Check] [Status: Sent to Queue]")
    p_urls= subprocess.Popen(f"echo {domain} | ./subTakeover.sh",shell=True)
    print("[Task: Subdomain Takeover Check] [Status: Completed]")


def urls():
    print("[Task: URL Gathering] [Status: Sent to Queue]")
    p_urls= subprocess.Popen(f"echo {domain} | ./urls.sh",shell=True)
    print("[Task: URL Gathering] [Status: Completed]")


if __name__ == '__main__':

    os.system('clear')
    print("<---------Go hunt for the bugs, leave recon on me--------->")
    thread_subdomains = threading.Thread(target=subdomains)
    thread_urls = threading.Thread(target=urls)
    thread_subTakeover = threading.Thread(target=subTakeover)

    thread_subdomains.start()
    thread_subdomains.join()

    thread_subTakeover.start()
    thread_urls.start()
    