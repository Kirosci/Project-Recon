import argparse
import subprocess
parser = argparse.ArgumentParser()

parser.add_argument("-ssrf", help="If you want to perfrom SSRF testing")

domain="newway"

args = parser.parse_args()
c = ("%s" % args.ssrf)

def ssrf(link): 


    p_urls= subprocess.run(f"newway/ssrf.sh {domain} {c}",shell=True)

ssrf(c)
