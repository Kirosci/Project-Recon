#!/bin/bash

# Ensure that Go is installed
if ! command -v /usr/local/go/bin/go &> /dev/null; then
    echo "Go is not installed. Please install Go and try again."
    exit 1
fi

# Update and Upgrade
sudo apt update &
wait
sudo apt upgrade &
wait

sudo apt install curl &
wait

curl https://go.dev/dl/go1.21.5.linux-amd64.tar.gz -L --output go1.21.5.linux-amd64.tar.gz &
wait

sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz

export PATH=$PATH:/usr/local/go/bin


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

wait

# Move all go binaries to bin
sudo mv go/bin/* /usr/local/go/bin/ &
wait

# PIP3 INSTALL
sudo apt-get install python3-pip &
wait

# Subdominator Install
pip3 install subdominator

# Waymore Install
git clone https://github.com/xnl-h4ck3r/waymore.git
cd waymore
sudo python3 setup.py install


# Check if there were any installation errors
if [ $? -eq 0 ]; then
    echo "All Go tools have been installed successfully."
else
    echo "Error occurred during installation. Please check the output for details."
fi
