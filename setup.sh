#!/bin/bash


allTools=("assetfinder" "dnsresolver" "jsluice" "unfurl" "hakrawler" "ffuf" "subjs" "massdns" "fetcher" "subfinder" "amass" "subdominator" "haktrails" "waymore" "katana" "gau" "waybackurls" "nuclei" "kxss" "qsreplace" "dirsearch" "httpx" "dnsgen" "altdns" "alterx" "puredns")

commonUtilties=("python3" "pip3" "sed" "gawk" "coreutils" "curl" "git" "jq" "net-tools" "tmux" "unzip" "zip" "dnsutils" "nmap")

missingTools=()
missingAgain=()
packetManager=""
allPresent=0

mkdir -p ~/tools


installmissingTools(){

    for tool in ${missingTools[@]}; do
        
        case $tool in

        # Subdomain gathering tools
            "amass")
                /usr/local/go/bin/go install -v github.com/owasp-amass/amass/v4/...@master
                ;;
            "assetfinder")
                /usr/local/go/bin/go install -v github.com/tomnomnom/assetfinder@latest
                ;;
            "haktrails")
                /usr/local/go/bin/go install -v github.com/hakluke/haktrails@latest
                ;;
            "subdominator")
                pip3 install git+https://github.com/RevoltSecurities/Subdominator
                ;;
            "subfinder")
                /usr/local/go/bin/go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
                ;;
            "dnsgen")
                python -m pip install dnsgen
                ;;
            "altdns")
                pip3 install "py-altdns"
                ;;
            "alterx")
                /usr/local/go/bin/go install github.com/projectdiscovery/alterx/cmd/alterx@latest
                ;;
            "puredns")
                /usr/local/go/bin/go install github.com/d3mondev/puredns/v2@latest
                ;;
            "massdns")
                git clone https://github.com/blechschmidt/massdns.git && cd massdns && make && mv bin/massdns /usr/local/bin/ && cd ../ && rm -rf massdns
                ;;
            "dnsresolver")
                git clone https://github.com/ethicalhackingplayground/dnsresolver ; cd dnsresolver ; cargo install --path .                ;;
            "ffuf")
                /usr/local/go/bin/go install github.com/ffuf/ffuf/v2@latest
                ;;


        # URL gathering tools
            "gau")
                /usr/local/go/bin/go install -v github.com/lc/gau/v2/cmd/gau@latest
                ;;
            "katana")
                /usr/local/go/bin/go install -v github.com/projectdiscovery/katana/cmd/katana@latest 
                ;;
            "waybackurls")
                /usr/local/go/bin/go install -v github.com/tomnomnom/waybackurls@latest
                ;;
            "waymore")
                pip3 install git+https://github.com/xnl-h4ck3r/waymore.git -v
                ;;
            "hakrawler")
                /usr/local/go/bin/go install -v github.com/hakluke/hakrawler@latest
                ;;



        # Misc Tools
            "dirsearch")
                pip3 install dirsearch
                ;;
            "tld")
                pip3 install tld
                ;;
            "kxss")
                /usr/local/go/bin/go install -v github.com/Emoe/kxss@latest
                ;;
            "nuclei")
                /usr/local/go/bin/go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
                ;;
            "qsreplace")
                /usr/local/go/bin/go install -v github.com/tomnomnom/qsreplace@latest
                ;;
            "httpx")
                /usr/local/go/bin/go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
                ;;
            "fetcher")
                /usr/local/go/bin/go install -v github.com/shivpratapsingh111/fetcher@latest
                ;;
            "unfurl")
                /usr/local/go/bin/go install -v github.com/tomnomnom/unfurl@latest
                ;;
            "subjs")
                /usr/local/go/bin/go install -v github.com/lc/subjs@latest
                ;;
            "jsluice")
                /usr/local/go/bin/go install github.com/BishopFox/jsluice/cmd/jsluice@latest
                ;;
            *)
                echo "[+] Installation method not added for: $tool"
                ;;
        esac
    done

    if [ $(ls ~/go/bin | wc -l) -gt 0 ]; then
        sudo mv ~/go/bin/* /usr/bin/
    fi
}





fixMissingAgain(){
    for tool in ${missingAgain[@]}; do
        echo "[+] Fixing misses"
        sudo pip3 uninstall -y $tool
        echo "[+] Fixed misses"
    done

    installmissingTools
}





checkTools(){
# Checking for missing tools

    for tool in "${allTools[@]}"; do
    
        if ! command -v $tool &>/dev/null; then
            missingTools+=("$tool")
            
        fi
    done
    
    if [ ${#missingTools[@]} -gt 0 ]; then
        echo "[+] Following tools are missing: "
        echo "---"
        for tool in ${missingTools[@]}; do
            echo "- ""$tool"
        done
        echo "---"
        echo ""
        installmissingTools

    fi


# Checking and fixing errors for still missing tools (that may not got installed due to some errors)
    for tool in "${allTools[@]}"; do
    
        if ! command -v $tool &>/dev/null; then
            missingAgain+="$tool"
        fi
    done

    if [ ${#missingAgain[@]} -gt 0 ]; then
        fixMissingAgain
    fi


# Checking if all tools are installed
    for tool in "${allTools[@]}"; do
    
        if ! command -v $tool &>/dev/null; then
            allPresent+=1
        fi
    done

    if [ $allPresent -gt 0 ]; then
        continue
    else
        echo "[+] All required tools are installed"
        echo "[+] Set API keys in config file for waymore & subfinder"
        echo -e "[+] Run below command to change timezone if you are using a VPS:\nsudo timedatectl set-timezone Asia/Kolkata"
    fi

# Printing name of tools, that were unable to install
    for tool in "${allTools[@]}"; do
    
        if ! command -v $tool &>/dev/null; then
            echo "[+] Not Installed, Install manually $tool"
            echo "[+] Don't forget to set API keys in config file for waymore & subfinder"
            echo -e "[+] Run below command to change timezone if you are using a VPS:\nsudo timedatectl set-timezone Asia/Kolkata"
            
        fi
    done

}




updateUpgrade() {

    if [ -f /etc/debian_version ]; then

        isDebian=1

        echo "[+] OS: Debian"
        
        sudo apt update -y
        sudo apt full-upgrade -y
        sudo apt autoremove -y
        sudo apt install dnsutils -y

        sudo apt install -y curl build-essential
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        source $HOME/.cargo/env


        apt install -y python3-pip && echo "[+] Python Installed" || echo "[+] Python Not Installed" | tee -a log.txt
        apt install -y python3.11-venv && echo "[+] Python venv Installed" || echo "[+] Python venv not Installed" | tee -a log.txt
        dir=$(pwd)
        cd ~ && echo "[+] Dir changed to '~'" || echo "[+] Dir didn't changed to '~'" | tee -a log.txt
        python3 -m venv .venvPython && echo "[+] Python vevnv made" || echo "[+] Python vevnv not made  " | tee -a log.txt
        source .venvPython/bin/activate && echo "[+] Python vevnv activated" || echo "[+] Python venv not activated" | tee -a log.txt
        cd $dir  && echo "[+] Directory changed to $dir" || echo "[+] Directory not changed to $dir" | tee -a log.txt
#        echo "#!/bin/bash" >> ~/.activatePythonVenv.sh
#        echo "source ~/.venvPython/bin/activate" >> ~/.activatePythonVenv.sh
#        chmod +x ~/.activatePythonVenv.sh

        if [ "$(echo $SHELL)" = "/bin/bash" ]; then
            echo 'source ~/.venvPython/bin/activate' >> ~/.bashrc && echo "[+] Python vevnv activate added to bashrc" || echo "[+] Python vevnv activate not added to bashrc" | tee -a log.txt
            source ~/.bashrc
        elif [ "$(echo $SHELL)" = "/bin/zsh" ]; then
            echo 'source ~/.venvPython/bin/activate' >> ~/.zshrc && echo "[+] Python vevnv activate added to zshrc" || echo "[+] Python vevnv activate not added to zshrc" | tee -a log.txt
            source ~/.zshrc
        else
            echo "Neither Bash nor Zsh is detected as the default shell. Please change your shell to one of these"
        fi 
        pip3 install colorama




        for utility in ${commonUtilties[@]}; do

            if [ $utility == "coreutils" ]; then

                if ! command -v cut &>/dev/null; then

                    echo "[+] $utility not present, Installing..."
                    sudo apt install coreutils -y

                fi
            
            elif [ $utility == "dnsutils" ]; then
            
                if ! command -v cut &>/dev/null; then

                    echo "[+] $utility not present, Installing..."
                    sudo apt install dnsutils -y

                fi

            elif ! command -v $utility &>/dev/null; then

                echo "[+] $utility not present, Installing..."
                sudo apt install $utility -y

            fi
            
        done      


    elif [ -f /etc/fedora-release ]; then

        echo "[+] OS: Fedora"

        sudo dnf update -y
        sudo dnf clean all -y
        sudo dnf install dnsutils -y

        sudo dnf install -y curl make gcc
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        source $HOME/.cargo/env


        for utility in ${commonUtilties[@]}; do

            if [ $utility == "coreutils" ]; then

                if ! command -v cut &>/dev/null; then

                    echo "[+] $utility not present, Installing..."
                    sudo dnf install coreutils -y

                fi
            
            elif [ $utility == "dnsutils" ]; then
            
                if ! command -v cut &>/dev/null; then

                    echo "[+] $utility not present, Installing..."
                    sudo dnf install dnsutils -y

                fi

            elif ! command -v $utility &>/dev/null; then

                echo "[+] $utility not present, Installing..."
                sudo dnf install $utility -y

            fi

        done      


    elif [ -f /etc/arch-release ]; then

        echo "[+] OS: Arch"

        sudo pacman -Syu
        sudo pacman -S dnsutils -y

        sudo pacman -S --needed curl base-devel
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        source $HOME/.cargo/env


        for utility in ${commonUtilties[@]}; do

            if [ $utility == "coreutils" ]; then

                if ! command -v cut &>/dev/null; then

                    echo "[+] $utility not present, Installing..."
                    pacman -S coreutils

                fi

            elif [ $utility == "dnsutils" ]; then
            
                if ! command -v cut &>/dev/null; then

                    echo "[+] $utility not present, Installing..."
                    pacman -S dnsutils

                fi

            elif ! command -v $utility &>/dev/null; then

                echo "[+] $utility not present, Installing..."
                pacman -S $utility

            fi
            
        done  

    fi

# Installing resolvers for Puredns from trickest
    if ! [ -f '~/.config/puredns/resolvers.txt' ]; then
        mkdir -p ~/.config/puredns
        wget "https://raw.githubusercontent.com/trickest/resolvers/main/resolvers.txt" 1> /dev/null
        wait
        mv resolvers.txt ~/.config/puredns/resolvers.txt
    fi
    

    
# Checking & Installing Go Lang
 
    if ! command -v /usr/local/go/bin/go &> /dev/null; then
        echo "Go is not installed. Installing..."
        curl https://go.dev/dl/go1.22.3.linux-amd64.tar.gz -L --output go1.22.3.linux-amd64.tar.gz &
        wait
        sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.22.3.linux-amd64.tar.gz & 
        wait
        export PATH=$PATH:/usr/local/go/bin
        rm go1.22.3.linux-amd64.tar.gz
    fi

}


# Driver Code
mainFunction(){
if [ "$EUID" -ne 0 ]
  then echo "Please run $0 as root"
  exit
fi

updateUpgrade
checkTools

if [[ $isDebian -eq 1 ]]; then
    clear
    echo "[+] All required tools are installed"
    echo "[+] Set API keys in config file for waymore & subfinder"
    echo -e "[+] Run below command to change timezone if you are using a VPS:\nsudo timedatectl set-timezone Asia/Kolkata"
    if [ "$(echo $SHELL)" = "/bin/bash" ]; then
        echo -e "[+] Please log out and log in again, or use below command:\nsource ~/.bashrc"
    elif [ "$(echo $SHELL)" = "/bin/zsh" ]; then
        echo -e "[+] Please log out and log in again, or use below command:\nsource ~/.zshrc"
    else
        echo "Neither Bash nor Zsh is detected as the default shell. Please change your shell to one of these"
    fi 
fi
}


# Calling mainFunction
mainFunction


