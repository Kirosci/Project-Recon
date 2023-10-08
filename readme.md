## Usage:

### Below 2 commands does the same work:
`python3 main.py -f domains.txt -all https://burpcollaborator.link`

`python3 main.py -f domains.txt -sub -tkovr -urls -xss -ssrf https://burpcollaborator.link`

### Incase you already found subdomains you do not need to find it again, you can remove **-sub** argument:
`python3 main.py -f domains.txt -tkovr -urls -xss -ssrf https://burpcollaborator.link`

### Incase you already found subdomains and checked for takeover then, you do not need repeat them again, you can remove **-sub** & **-tkovr** arguments:
`python3 main.py -f domains.txt -urls -xss -ssrf https://burpcollaborator.link`

#### NOTE: Like above 2 examples you can exclude and include arguments accordingly.

### Update:
You can update your script to latest version.
Example: `python3 main.py -update`

### Subdomains:
There will be two files `subdomains.txt` this will contain all subdomains found using various tool, and `live_subdomains.txt` this file will contain all live subdomains. 
#### Amass Timeout:
        * Added amass timeout feature thet you can use with -sub or -all argument to specify timeout for amass tool.
        * By default it is set to 30 mins
        * `-amass_t 0` for not setting any timeout
        * `-amass_t 60` for 60 minutes timeout 

### URLs: 
Check `urls.txt` will contain all the URLs and `js_urls.txt`  will contain all the *JavaScript* file URLs found by grepping from the discovered URLs. 

### Subdomain Takeover:
Check `subTakeover.txt` file it will contain all the subdomains with **status code:404** and having some **CNAME**

### XSS:
Check `kxss.txt` file it contains all the URL with reflected parameters and all allowed characters on that parameter. 

### SSRF:
For SSRF testing you just provide the Server URL (Burp collaborator, Interactsh, Canary Token) to it , add it will send the request if in case you got the hit, check the query section, there will be a number like `?no=123` then go to `all_ssrf_urls.txt`file (each URL in this file is assigned with a unique number) and search for that number you will get to know the URL that SSRF vulnerable URL.

![image](https://github.com/Kirosci/Project-Recon/assets/106021529/6950b0ce-3ac5-4b22-8bdb-d57895684f9b)
![image](https://github.com/Kirosci/Project-Recon/assets/106021529/40e4ca81-664e-4a07-9c8b-51897b07226d)


### Nuclei:
Check `nuclei.txt` file it will contain all the nuclei results. 
