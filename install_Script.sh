#!/bin/bash

# Ensure that Go is installed
if ! command -v go &> /dev/null; then
    echo "Go is not installed. Please install Go and try again."
    exit 1
fi

# Install Go tools
go install -v github.com/owasp-amass/amass/v4/...@master &
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest &
go install -v github.com/tomnomnom/assetfinder@latest &
go install -v github.com/hakluke/haktrails@latest &
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest &
go install -v github.com/Emoe/kxss@latest &
go install -v github.com/tomnomnom/qsreplace@latest &
go install -v github.com/projectdiscovery/katana/cmd/katana@latest &
go install -v github.com/lc/gau/v2/cmd/gau@latest &
go install github.com/tomnomnom/waybackurls@latest &



# Wait for all background jobs to finish
wait

# PIP3 INSTALL
sudo apt-get install python3-pip &
wait

# Subdominator Install
pip3 install subdominator

# Waymore Install
git clone https://github.com/xnl-h4ck3r/waymore.git
cd waymore
sudo python setup.py install


# Check if there were any installation errors
if [ $? -eq 0 ]; then
    echo "All Go tools have been installed successfully."
else
    echo "Error occurred during installation. Please check the output for details."
fi

