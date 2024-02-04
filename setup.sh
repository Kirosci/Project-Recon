#!/bin/bash

# Ensure that Go is installed
if ! command -v /usr/local/go/bin/go &> /dev/null; then
    echo "Go is not installed. Installing..."
    curl https://go.dev/dl/go1.21.5.linux-amd64.tar.gz -L --output go1.21.5.linux-amd64.tar.gz &
    wait
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz & 
    wait
    export PATH=$PATH:/usr/local/go/bin
fi

# Update and Upgrade
sudo apt update &
wait
echo "y" | sudo apt upgrade &
wait

mkdir ~/tools

sudo apt install curl &
wait


# Install Go tools
/usr/local/go/bin/go install -v github.com/owasp-amass/amass/v4/...@master &
/usr/local/go/bin/go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest &
/usr/local/go/bin/go install -v github.com/tomnomnom/assetfinder@latest &
/usr/local/go/bin/go install -v github.com/hakluke/haktrails@latest &
/usr/local/go/bin/go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest &
/usr/local/go/bin/go install -v github.com/Emoe/kxss@latest &
/usr/local/go/bin/go install -v github.com/tomnomnom/qsreplace@latest &
/usr/local/go/bin/go install -v github.com/projectdiscovery/katana/cmd/katana@latest &
/usr/local/go/bin/go install -v github.com/lc/gau/v2/cmd/gau@latest &
/usr/local/go/bin/go install -v github.com/tomnomnom/waybackurls@latest &
/usr/local/go/bin/go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest &

wait

# Move all go binaries to bin
sudo mv ~/go/bin/* /usr/bin/

# PIP3 INSTALL
sudo apt-get install python3-pip &
wait

# Subdominator Install
pip3 install subdominator &

# Dirsearch Install
pip3 install dirsearch &

wait

# Waymore Install
cd ~/tools
git clone https://github.com/xnl-h4ck3r/waymore.git
cd waymore
sudo python3 setup.py install


# Project Recon Install
cd ~/tools
git clone https://github.com/shivpratapsingh111/Project-Recon.git

unzip cent-nuclei-templates

wait


rm -rf Backup TODO 1&>2 /dev/null

# Check if there were any installation errors
if [ $? -eq 0 ]; then
    echo "All Go tools have been installed successfully"
    echo "Manually Setup Haktrails API"
else
    echo "Error occurred during installation. Please check the output for details."
fi
