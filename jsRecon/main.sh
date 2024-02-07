#!/bin/bash

# Initialize variables
directory=""
file=""
find_flag=false
string_to_find=""

# Function to print usage
usage() {
    echo "Usage: $0 [-dir <directory>] [-f <file>] [-find <string> -d <directory>]"
    exit 1
}

# Parse command-line arguments
while [ "$#" -gt 0 ]; do
    case "$1" in
        -dir)
            shift
            directory="$1"
            ;;
        -f)
            shift
            file="$1"
            ;;
        -find)
            find_flag=true
            shift
            string_to_find="$1"
            ;;
        -d)
            shift
            directory="$1"
            ;;
        *)
            usage
            ;;
    esac
    shift
done

# Function to process directory
process_directory() {
    local output_index=1
    cd "$1" || exit
    for file in *.js; do
        if jsluice urls "$file" | jq | tee "${output_index}_urls.txt"; then
            ((output_index++))
        else
            continue
        fi
    done &

    for file in *.js; do
        if jsluice secrets "$file" | jq | tee "${output_index}_secrets.txt"; then
            ((output_index++))
        else
            continue
        fi
    done

    wait

    cat *_urls.txt > combinedUrls.txt &
    cat *_secrets.txt > secretsOnly.txt

    wait

    cat combinedUrls.txt | jq -r '.url' | grep -v -E '^(https?:)?//' | awk 'length($0) < 50000 && /^\// {print}' | sort -u | tee pathsOnly.txt &
    cat combinedUrls.txt | jq -r '.url' | grep -Eo 'https?://[^[:space:]]+' | sort -u | tee urlsOnly.txt
    wait
}

# Function to process single file
process_file() {
    if [ ! -f "$1" ]; then
        echo "File $1 not found."
        exit 1
    fi
    jsluice urls "$1" | jq | tee "urls.txt" &
    jsluice secrets "$1" | jq | tee "secrets.txt"
    wait

    cat urls.txt | jq -r '.url' | grep -v -E '^(https?:)?//' | awk 'length($0) < 50000 && /^\// {print}' | sort -u | tee pathsOnly.txt &
    cat urls.txt | jq -r '.url' | grep -Eo 'https?://[^[:space:]]+' | sort -u | tee urlsOnly.txt
    wait

    rm urls.txt
}

# Function to find string in directory
find_string_in_directory() {
    local directory="$1"
    local string_to_find="$2"
    grep -A 5 -r "$string_to_find" "$directory"/combinedUrls.txt | grep filename | sort -u
}

# Execute based on the flags provided
if [ "$directory" != "" ]; then
    if [ "$find_flag" = true ]; then
        find_string_in_directory "$directory" "$string_to_find"
    else
        process_directory "$directory"
    fi
elif [ "$file" != "" ]; then
    process_file "$file"
else
    usage
fi
