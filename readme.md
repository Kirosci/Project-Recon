# Usage:

#### NOTE: You can use this tool to do tasks one at a time. [If your PC doesn't have enough resources]
* Example:
   * Incase you only need to find subdomains then use, `python3 main.py -f domain.txt -sub`
   * Now you need urls only no worries, just use `python3 main.py -f domains.txt -urls` you don't need to specify -sub flag again. It will use the lastly found subdomains.

---

### > Update (-update):
You can update your script to latest version.
Example: `python3 main.py -update`

---

### > All (-all):
`python3 main.py -f domains.txt -all https://burpcollaborator.link`

This will work same as the below command, It will do each and every task.

`python3 main.py -f domains.txt -sub -tkovr -urls -fuzz -xss -nmap -js -nuclei -ssrf https://burpcollaborator.link`

---

### > Subdomains (-sub):
There will be two files `subdomains.txt` this will contain all subdomains found using various tool, and `liveSubdomains.txt` this file will contain all 200 OK subdomains.
* -sub ps (Passive Gathering)
  * Gather domains from passive sources. (Securitytrails, Assetfinder, Subdominator, Subfinder)
* -sub ac (Active Gathering)
  * Makes a custom wordlists of subdomains, and resolves them.
* Amass Timeout (-amass_t):
  * Added amass timeout feature thet you can use with -sub or -all argument to specify timeout for amass tool.
  * By default amass will not run
  * `-amass_t 0` for not using amass
  * `-amass_t 1` for not setting any timeout, it will run until it gets stoped by itself.
  * `-amass_t 60` for 60 minutes timeout

---

### > URLs (-urls): 
Check `urls.txt` file for all the URLs and `jsUrls.txt`  will contain all the *JavaScript & Json* file URLs found by grepping from the discovered URLs.
* -urls ps (Passive Gathering)
  * Gather urls from passive sources. (wayback, gau, waymore)
* -urls ac (Active Gathering)
  * Gather urls by crawling. (katana)

---

### > Subdomain Takeover (-tkovr):
Check `subTakeover.txt` file for all the subdomains with **status code:404** and having some **CNAME**

---

### > XSS (-xss):
Check `xss.txt` file for all the URLs with reflected parameters and all allowed special characters on that parameter. 

---

### > SSRF (-ssrf):
For SSRF testing you just provide the Server URL (Burp collaborator, Interactsh, Canary Token) to it , add it will send the request if in case you got the hit, check the query section, there will be a number like `?no=123` then go to `ssrfUrls.txt`file (each URL in this file is assigned with a unique number) and search for that number you will get to know the URL that SSRF vulnerable URL.

![image](https://github.com/Kirosci/Project-Recon/assets/106021529/6950b0ce-3ac5-4b22-8bdb-d57895684f9b)
![image](https://github.com/Kirosci/Project-Recon/assets/106021529/40e4ca81-664e-4a07-9c8b-51897b07226d)
* In above image it is ssrfUrls.txt in place of all_ssrf_urls.txt

---

### > Nuclei (-nuclei):
Check `nuclei.txt` file for results. 

---

### > Fuzz (-fuzz):
It uses a mix of wordlists to fuzz:

Results are saved in fuzz.txt file, while seperate results for each wordlist are saved in /fuzz

---

### > JS recon (-js):
Check `js/` directory for all the results, It will contain paths, urls and juicy stuff found from js files

---

### > Nmap (-nmap):
Check `nmap/` directory for results

---
