## Usage:

### Below 2 commands does the same work:
`python3 main.py -f domains.txt -all https://burpcollaborator.link`

`python3 main.py -f domains.txt -sub -tkovr -urls -xss -ssrf https://burpcollaborator.link`

### Incase you already found subdomains you do not need to find it again, you can remove **-sub** argument:
`python3 main.py -f domains.txt -tkovr -urls -xss -ssrf https://burpcollaborator.link`

### Incase you already found subdomains and checked for takeover then, you do not need repeat them again, you can remove **-sub** & **-tkovr** arguments:
`python3 main.py -f domains.txt -urls -xss -ssrf https://burpcollaborator.link`

#### NOTE: Like above 2 examples you can exclude and include arguments if you want to run the tool again but you already have some found somethings.
