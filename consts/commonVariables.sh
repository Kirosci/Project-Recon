#!/bin/bash

# ====

# This file hold variables common several scripts.

# ====

# Filename to save subdomain enumeration results
Dir_SubdomainResults='subdomains.txt'

# Filename to save results of URL enumeration
UrlResults='urls.txt'

# Filename to save JavaScript endpoints 
jsUrls='jsUrls.txt'

# $baseDir will hold path to main directory (Project-Recon)
baseDir="$(pwd)" # /home/cyrusop/vsCode/Project-Recon (In my case)

# Filename for temporary file, write anything to it then remove it.
# Mostly, I use it when I have to do some changes to a file, I do changes and write it to temporary file then rename it back to original file
tempFile='tempFile.txt'