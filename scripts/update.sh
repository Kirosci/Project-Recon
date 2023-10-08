#!/bin/bash

current_dir=$(basename "$PWD")

ls
read -p "Do you want to remove all these data along? [y/n]: " option
if [ "$option"="y" ]; then
    option=1    
else
    option=0
fi

if [ "$current_dir" == "Project-Recon" ]; then

    if [ "$option" -eq 1 ]; then
        rm -rf *
    else
        rm -rf main.py .git scripts Backup readme.md    
    fi
    
    git clone https://github.com/shivpratapsingh111/Project-Recon.git
    mv Project-Recon/* ./
    rm -rf Project-Recon
else
    echo "The current directory is not named 'Project-recon'."
fi
