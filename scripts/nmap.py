import os
import sys
import subprocess
from concurrent.futures import ThreadPoolExecutor, as_completed

def scan_ip_range(domain, ip_range):
    # Navigate to the domain directory
    domain_dir = os.path.join('results', domain)

    os.makedirs('nmap', exist_ok=True)
    os.chdir(domain_dir)
    
    # Run nmap for the given IP range
    print(f"[+] Started Nmap for {ip_range}")
    file_name = ip_range.replace('/', '_')
    if os.path.exists(f"nmap/nmapGrepableOutput_{file_name}.txt"):
        print(f"Skipping `{ip_range}`..., Scan for this range already exists at nmap/nmapGrepableOutput_{file_name}.txt")
    else:
        nmap_command = f"nmap -v --host-timeout=28800s -Pn -T4 -sT -sV --max-retries=1 --open {ip_range} --script=default -p 0-1024,10000,1010,10250,10443,1099,11371,12043,12046,12443,1311,15672,16080,17778,18091,18092,20720,2082,2087,2095,2096,21,22,2480,280,28017,300,3000,3128,32000,3333,3389,4243,443,4444,4445,4567,4711,4712,4993,5000,5001,5104,5108,5280,5281,55440,55672,5601,5800,583,591,593,6543,7000,7001,7002,7396,7474,80,8000,8001,8008,8009,8014,8042,8060,8069,8080,8081,8083,8088,8090,8091,8095,81,8118,8123,8172,8181,8222,8243,8280,8281,832,8333,8337,8443,8500,8530,8531,8800,8834,8880,8887,8888,8983,9000,9001,9043,9060,9080,9090,9091,9092,9200,9443,9502,9800,981,9981 -oG nmap/nmapGrepableOutput_{file_name}.txt 1> /dev/null" 
        subprocess.run(nmap_command, shell=True, check=True)

        # Return to the base directory
    os.chdir(base_dir)

def scan_ip_ranges(domain_file, ip_ranges_file):
    # Read domain list from file
    with open(domain_file, 'r') as df:
        domains = [line.strip() for line in df if line.strip()]

    # Read IP ranges from file
    with open(ip_ranges_file, 'r') as irf:
        ip_ranges = [line.strip() for line in irf if line.strip()]

    # Execute scanning in parallel using ThreadPoolExecutor
    with ThreadPoolExecutor(max_workers=10) as executor:
        futures = []
        for domain in domains:
            for ip_range in ip_ranges:
                futures.append(executor.submit(scan_ip_range, domain, ip_range))

        # Wait for all tasks to complete
        for future in as_completed(futures):
            try:
                future.result()  # Ensure any exceptions are propagated
            except Exception as e:
                print(f"Exception occurred: {e}")

if __name__ == "__main__":
    base_dir = os.getcwd()  # Get the current working directory
    domain_file = sys.argv[1]

    with open(domain_file, 'r') as file:
        for domain in file:
            ip_ranges_file = f"results/{domain.strip()}/ipRanges.txt"  # Update with your IP ranges file path
            scan_ip_ranges(domain_file, ip_ranges_file)
