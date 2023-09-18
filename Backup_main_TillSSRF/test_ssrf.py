import argparse
import subprocess
from colorama import Fore, Back, Style

parser = argparse.ArgumentParser()

parser.add_argument("-ssrf", help="If you want to perfrom SSRF testing")

domain="thecyberboy.com"

args = parser.parse_args()
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


if args.ssrf:
    link = ("%s" % args.ssrf)
    ssrf(link)
    # thread_ssrf = threading.Thread(target=subTakeover, args=(domain,link,))
    # thread_ssrf.start()
else:
    print(Fore.RED + "[Step: SSRF Testing]", end=" ")
    print(Fore.BLUE + "[Info:Something went wrong]")
