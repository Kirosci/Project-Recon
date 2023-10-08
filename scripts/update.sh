#!/bin/bash

current_dir=$(basename "$PWD")

if [ "$current_dir" == "Project-Recon" ]; then
    git clone https://github.com/shivpratapsingh111/Project-Recon.git

    rm -rf main.py .git scripts Backup readme.md    
    mv Project-Recon/* ./
    rm -rf Project-Recon
else
    echo "The current directory is not named 'Project-recon'."
fi
