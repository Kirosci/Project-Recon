#!/bin/bash

# Initialize variables
directory=""
file=""
find_flag=false
stringToFind=""


usage() {
    echo -e "\nUsage: \n $0 [-dir <directory> OR -f <file>] OR [-find <string> AND -d <directory>]\n\nUse \`=\` between flag and data"
    exit 1
}

# Function for directory of js files (-dir)
scanDirectory() {
    directory=$1
    cd "$directory" || exit
    # mkdir -p jsSourceFiles
    for file in *.js; do
        if jsluice urls "$file" | jq | tee "${file}_urls.txt"; then
        echo "1" 1> /dev/null
        else
            continue
        fi
    done &

    for file in *.js; do
        if jsluice secrets "$file" | jq | tee "${file}_secrets.txt"; then
        echo "1" 1> /dev/null
        else
            continue
        fi
    done

    wait

    cat *_urls.txt > .jsLuiceCombinedUrls.txt
    cat *_secrets.txt > secrets.txt

    rm *_urls.txt
    rm *_secrets.txt 

    wait

    cat .jsLuiceCombinedUrls.txt | jq -r '.url' | grep -v -E '^(https?:)?//' | awk 'length($0) < 50000 && /^\// {print}' | sort -u | tee paths.txt
    cat .jsLuiceCombinedUrls.txt | jq -r '.url' | grep -Eo 'https?://[^[:space:]]+' | sort -u | tee urls.txt
    wait
    # mv *.js jsSourceFiles
    mv *.txt ../
}

# Function for a single javascript (-f)
scanFile() {
    if [ ! -f "$1" ]; then
        echo "File $1 not found."
        exit 1
    fi
    jsluice urls "$1" | jq | tee "urls.txt"
    jsluice secrets "$1" | jq | tee "secrets.txt"
    wait

    cat urls.txt | jq -r '.url' | grep -v -E '^(https?:)?//' | awk 'length($0) < 50000 && /^\// {print}' | sort -u | tee paths.txt
    cat urls.txt | jq -r '.url' | grep -Eo 'https?://[^[:space:]]+' | sort -u | tee urls.txt
    wait
    
}

# Function to find provided string in directory of js files (-find and -d)
findString() {
    local directory="$1"
    local stringToFind="$2"
    grep -A 5 -r "$stringToFind" "$directory"/.jsLuiceCombinedUrls.txt | grep filename | sort -u
}


# Defining command-line arguments
arg1Data="$(echo $1 | cut -d "=" -f2)"
arg1="$(echo $1 | cut -d "=" -f1)"

arg2Data="$(echo $2 | cut -d "=" -f2)"
arg2="$(echo $2 | cut -d "=" -f1)"


if [ "$arg1" == "-find" ] && [ "$arg2" == "-d" ] ; then
# Ensure $1 must be directory and $2 must be string
    findString "$arg2Data" "$arg1Data"
elif [ "$arg1" == "-d" ] &&  [ "$arg2" == "-find" ]; then
# Ensure $1 must be directory and $2 must be string
    findString "$arg1Data" "$arg2Data"

elif [ "$arg1" == "-dir" ]; then
    scanDirectory "$arg1Data"

elif [ "$arg1" == "-f" ]; then
    scanFile "$arg1Data"

else
    usage
fi

