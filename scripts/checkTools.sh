allTools=("assetfinder" "jsluice" "unfurl" "hakrawler" "subjs" "massdns" "fetcher" "subfinder" "amass" "subdominator" "haktrails" "waymore" "katana" "gau" "waybackurls" "nuclei" "kxss" "qsreplace" "dirsearch" "httpx" "dnsgen" "altdns" "alterx" "puredns")

commonUtilities=("python3" "pip3" "sed" "gawk" "coreutils" "curl" "git" "jq")

missingTools=()

checkTools() {
    allPresent=1
    # Checking for missing tools
    for tool in "${allTools[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            missingTools+=("$tool")
            allPresent=0
            echo "0"

        fi
    done

}

updateUpgrade() {
    if [ -f /etc/debian_version ]; then
        for utility in "${commonUtilities[@]}"; do
            if [ "$utility" == "coreutils" ]; then
                if ! command -v cut &>/dev/null; then
                    echo "0"
                    allPresent=0
                fi
            elif ! command -v "$utility" &>/dev/null; then
                echo "0"
                allPresent=0
            fi
        done
    elif [ -f /etc/fedora-release ]; then
        for utility in "${commonUtilities[@]}"; do
            if [ "$utility" == "coreutils" ]; then
                if ! command -v cut &>/dev/null; then
                    echo "0"
                    allPresent=0
                fi
            elif ! command -v "$utility" &>/dev/null; then
                echo "0"
                allPresent=0
            fi
        done
    elif [ -f /etc/arch-release ]; then
        for utility in "${commonUtilities[@]}"; do
            if [ "$utility" == "coreutils" ]; then
                if ! command -v cut &>/dev/null; then
                    echo "0"
                    allPresent=0
                fi
            elif ! command -v "$utility" &>/dev/null; then
                echo "0"
                allPresent=0
            fi
        done
    fi

    # Checking Go Lang
    if ! command -v /usr/local/go/bin/go &>/dev/null; then
        echo "0"
        allPresent=0
    fi
}

checkTools
updateUpgrade


if [[ $allPresent -eq 1 ]]; then
    echo "1"
fi