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

`python3 main.py -f domains.txt -sub -tkovr -urls -fuzz -xss -ssrf https://burpcollaborator.link`

---

### > Subdomains (-sub):
There will be two files `subdomains.txt` this will contain all subdomains found using various tool, and `live_subdomains.txt` this file will contain all live subdomains. 
* Amass Timeout (-amass_t):
  * Added amass timeout feature thet you can use with -sub or -all argument to specify timeout for amass tool.
  * By default it is set to 30 mins
  * `-amass_t 0` for not using amass
  * `-amass_t 1` for not setting any timeout, it will run until it gets stoped by itself.
  * `-amass_t 60` for 60 minutes timeout

---

### > URLs (-urls): 
Check `urls.txt` will contain all the URLs and `js_urls.txt`  will contain all the *JavaScript* file URLs found by grepping from the discovered URLs. 

---

### > Subdomain Takeover (-tkovr):
Check `subTakeover.txt` file it will contain all the subdomains with **status code:404** and having some **CNAME**

---

### > XSS (-xss):
Check `kxss.txt` file it contains all the URL with reflected parameters and all allowed characters on that parameter. 

---

### > SSRF (-ssrf):
For SSRF testing you just provide the Server URL (Burp collaborator, Interactsh, Canary Token) to it , add it will send the request if in case you got the hit, check the query section, there will be a number like `?no=123` then go to `all_ssrf_urls.txt`file (each URL in this file is assigned with a unique number) and search for that number you will get to know the URL that SSRF vulnerable URL.

![image](https://github.com/Kirosci/Project-Recon/assets/106021529/6950b0ce-3ac5-4b22-8bdb-d57895684f9b)
![image](https://github.com/Kirosci/Project-Recon/assets/106021529/40e4ca81-664e-4a07-9c8b-51897b07226d)

---

### > Nuclei (-nuclei):
Check `nuclei.txt` file it will contain all the nuclei results. 

---

### > Fuzz (-fuzz):
It uses GodFather's worlisits to fuzz:
* 1.txt
* apac.txt
* cgi-bin.txt
* fuzz.txt
* god.txt
* kibana.txt
* xml.txt
* pl.txt
* fuzz-php.php

Results are saved in fuzz.txt file, while seperate results for each wordlist are saved in /fuzz

---
