#!/bin/bash

current_dir=$(basename "$PWD")

if [ "$current_dir" == "Project-Recon" ]; then

    rm -rf main.py .git scripts Backup readme.md    
  
    git clone https://github.com/shivpratapsingh111/Project-Recon.git 2> /dev/null 
    mv Project-Recon/* ./
    mv Project-Recon/.* ./
    rm -rf Project-Recon
else
    echo "The current directory is not named 'Project-recon'."
fi
