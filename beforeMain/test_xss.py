import argparse
import subprocess
from colorama import Fore, Back, Style

parser = argparse.ArgumentParser()
parser.add_argument("-ssrf", help="Please give your Burp Collaborator link/Server link")

parser.add_argument("-xss", action='store_true', help="If you want to perform XSS testing")

args = parser.parse_args()

domain = "thecyberboy.com"

c = ("%s" % args.ssrf)

def ssrf(link): 
    print(Fore.BLUE + "[Task: SSRF Testing]", end=' ') 
    print (Fore.GREEN + "[Status: In progress]")
    print(Fore.WHITE + "    |---[Qsreplace]")
    print(Style.RESET_ALL)
    p_urls= subprocess.Popen(f"./ssrf.sh {domain} {link}",shell=True).wait()
    print('\n')
    print(Fore.BLUE + "[Task: SSRF Testing]", end=' ') 
    print (Fore.GREEN + "[Status: Completed]")
    print (Fore.CYAN + "[Info: Check if you get any pingbacks]")
    print(Style.RESET_ALL)

    # p_urls= subprocess.run(f"newway/ssrf.sh {domain} {link}",shell=True)
def xss():
    print(Fore.BLUE + "[Task: XSS Testing]", end=' ') 
    print (Fore.GREEN + "[Status: In progress]")
    print(Fore.WHITE + "    |---[KXSS]")
    print(Style.RESET_ALL)
    p_paramspider = subprocess.run(f"./xss.sh {domain}", shell=True)
    print(Fore.BLUE + "[Task: XSS Testing]", end=' ') 
    print (Fore.GREEN + "[Status: Completed]")
    print (Fore.CYAN + "[Info: Check *kxss.txt* file]")
    print(Style.RESET_ALL)

# if args.ssrf and args.xss:
#     link = ("%s" % args.ssrf)
#     ssrf(link)
#     xss()
#     # thread_ssrf = threading.Thread(target=subTakeover, args=(domain,link,))
#     # thread_ssrf.start()

if args.xss:
    
    xss()

elif args.ssrf:
    link = ("%s" % args.ssrf)
    ssrf(link)

else:
    print("Bye")







