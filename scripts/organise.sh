#!/bin/bash

GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
ORANGE=$(tput setaf 3)
RESET=$(tput sgr0) 

# Makiung seperate directory for organised results in main directory (Project-Recon)
mkdir -p organisedResults

# Making centralized directory for target
mkdir -p "organisedResults/$2" || { echo "Failed to create directory $2"; }

# Making centralized directory for all target results
mkdir -p "organisedResults/$2/all"


main() {
    # Moving all targets into centralized directory
    while IFS= read -r res; do
        cp -r "results/$res" "organisedResults/$2" || { echo "Failed to move $res to $2"; }
    done < "$1"

    # Centralized target dir path
    TARGET_DIR="organisedResults/$2"

    # Create the 'organized' folder in the centralized target directory
    ORGANIZED_DIR="$TARGET_DIR/.organised"
    mkdir -p "$ORGANIZED_DIR"



# ------------
# Moving screenshots dir
    # Create screenshots dir to move all screenshots in
    mkdir -p "$ORGANIZED_DIR/screenshots"

    for subdir in "$TARGET_DIR"/*/; do

        find "$subdir"screenshots/ -type f -exec cp {} "$ORGANIZED_DIR/screenshots" \;

    done
# ------------


# ------------
# Moving Fuzz dir
    mkdir -p "$ORGANIZED_DIR/fuzz"

    counter=0
    for subdir in "$TARGET_DIR"/*/; do
        # Ensure we're working with the screenshots directory within each subdirectory

        cp "$subdir"fuzz/fuzz_dirSmall.txt "$ORGANIZED_DIR/fuzz/fuzz_dirSmall$counter.txt" 2> /dev/null
        cp "$subdir"fuzz/fuzz_mixedBig.txt "$ORGANIZED_DIR/fuzz/fuzz_mixedBig$counter.txt" 2> /dev/null

        ((counter++))


    done
    cat "$ORGANIZED_DIR"/fuzz/fuzz_dirSmall*.txt > "$ORGANIZED_DIR"/fuzz/fuzz_dirSmall 2> /dev/null
    cat "$ORGANIZED_DIR"/fuzz/fuzz_mixedBig*.txt > "$ORGANIZED_DIR"/fuzz/fuzz_mixedBig 2> /dev/null

    rm "$ORGANIZED_DIR"/fuzz/*.txt 2> /dev/null

# ------------



# ------------
# Moving js dir
    mkdir -p "$ORGANIZED_DIR/js"

    counter=0
    for subdir in "$TARGET_DIR"/*/; do
        # Ensure we're working with the screenshots directory within each subdirectory

        cp "$subdir"js/jsNuclei.txt "$ORGANIZED_DIR/js/jsNuclei$counter.txt" 2> /dev/null
        cp "$subdir"js/paths.txt "$ORGANIZED_DIR/js/paths$counter.txt" 2> /dev/null
        cp "$subdir"js/secrets.txt "$ORGANIZED_DIR/js/secrets$counter.txt" 2> /dev/null
        cp "$subdir"js/urls.txt "$ORGANIZED_DIR/js/urls$counter.txt" 2> /dev/null

        ((counter++))


    done
    cat "$ORGANIZED_DIR"/js/jsNuclei*.txt > "$ORGANIZED_DIR"/js/jsNuclei 2> /dev/null
    cat "$ORGANIZED_DIR"/js/paths*.txt > "$ORGANIZED_DIR"/js/paths 2> /dev/null
    cat "$ORGANIZED_DIR"/js/secrets*.txt > "$ORGANIZED_DIR"/js/secrets 2> /dev/null
    cat "$ORGANIZED_DIR"/js/urls*.txt > "$ORGANIZED_DIR"/js/urls 2> /dev/null

    rm "$ORGANIZED_DIR"/js/*.txt 2> /dev/null

# ------------



# ------------
# Moving nmap dir
    mkdir -p "$ORGANIZED_DIR/nmap"
    for subdir in "$TARGET_DIR"/*/; do
        # Ensure we're working with the screenshots directory within each subdirectory

        cp "$subdir"nmap/*.txt "$ORGANIZED_DIR"/nmap 2> /dev/null


    done
    cat "$ORGANIZED_DIR"/nmap/*.txt > "$ORGANIZED_DIR"/nmap/nmap 2> /dev/null

    rm "$ORGANIZED_DIR"/nmap/*.txt 2> /dev/null
    mv nmap "$ORGANIZED_DIR"/nmap.txt 2> /dev/null
    rm -rf nmap/

# ------------



# ------------
# Moving subTakeovers.txt dir
    mkdir -p "$ORGANIZED_DIR/rest"

    counter=0
    for subdir in "$TARGET_DIR"/*/; do
        # Ensure we're working with the screenshots directory within each subdirectory

        cp "$subdir"urls.txt "$ORGANIZED_DIR/rest/urls$counter.txt" 2> /dev/null
        cp "$subdir"subdomains.txt "$ORGANIZED_DIR/rest/subdomains$counter.txt" 2> /dev/null
        cp "$subdir"liveSubdomains.txt "$ORGANIZED_DIR/rest/liveSubdomains$counter.txt" 2> /dev/null
        cp "$subdir"nuclei.txt "$ORGANIZED_DIR/rest/nuclei$counter.txt" 2> /dev/null
        cp "$subdir"xss.txt "$ORGANIZED_DIR/rest/xss$counter.txt" 2> /dev/null
        cp "$subdir"jsUrls.txt "$ORGANIZED_DIR/rest/jsUrls$counter.txt" 2> /dev/null
        cp "$subdir"openRedirects.txt "$ORGANIZED_DIR/rest/openRedirects$counter.txt" 2> /dev/null
        cp "$subdir"subTakeovers.txt "$ORGANIZED_DIR/rest/subTakeovers$counter.txt" 2> /dev/null

        ((counter++))


    done
    

    cat "$ORGANIZED_DIR"/rest/urls*.txt > "$ORGANIZED_DIR"/rest/urls 2> /dev/null 
    cat "$ORGANIZED_DIR"/rest/subdomains*.txt > "$ORGANIZED_DIR"/rest/subdomains 2> /dev/null
    cat "$ORGANIZED_DIR"/rest/liveSubdomains*.txt > "$ORGANIZED_DIR"/rest/liveSubdomains 2> /dev/null
    cat "$ORGANIZED_DIR"/rest/nuclei*.txt > "$ORGANIZED_DIR"/rest/nuclei 2> /dev/null
    cat "$ORGANIZED_DIR"/rest/xss*.txt > "$ORGANIZED_DIR"/rest/xss 2> /dev/null
    cat "$ORGANIZED_DIR"/rest/jsUrls*.txt > "$ORGANIZED_DIR"/rest/jsUrls 2> /dev/null
    cat "$ORGANIZED_DIR"/rest/openRedirects*.txt > "$ORGANIZED_DIR"/rest/openRedirects 2> /dev/null
    cat "$ORGANIZED_DIR"/rest/subTakeovers*.txt > "$ORGANIZED_DIR"/rest/subTakeovers 2> /dev/null
    
    rm "$ORGANIZED_DIR"/rest/urls*.txt 2> /dev/null
    rm "$ORGANIZED_DIR"/rest/subdomains*.txt 2> /dev/null
    rm "$ORGANIZED_DIR"/rest/liveSubdomains*.txt 2> /dev/null
    rm "$ORGANIZED_DIR"/rest/nuclei*.txt 2> /dev/null
    rm "$ORGANIZED_DIR"/rest/xss*.txt 2> /dev/null
    rm "$ORGANIZED_DIR"/rest/jsUrls*.txt 2> /dev/null
    rm "$ORGANIZED_DIR"/rest/openRedirects*.txt 2> /dev/null
    rm "$ORGANIZED_DIR"/rest/subTakeovers*.txt 2> /dev/null

    mv "$ORGANIZED_DIR"/rest/urls "$ORGANIZED_DIR"/urls.txt 2> /dev/null
    mv "$ORGANIZED_DIR"/rest/subdomains "$ORGANIZED_DIR"/subdomains.txt 2> /dev/null
    mv "$ORGANIZED_DIR"/rest/liveSubdomains "$ORGANIZED_DIR"/liveSubdomains.txt 2> /dev/null
    mv "$ORGANIZED_DIR"/rest/nuclei "$ORGANIZED_DIR"/nuclei.txt 2> /dev/null
    mv "$ORGANIZED_DIR"/rest/xss "$ORGANIZED_DIR"/xss.txt 2> /dev/null
    mv "$ORGANIZED_DIR"/rest/jsUrls "$ORGANIZED_DIR"/jsUrls.txt 2> /dev/null
    mv "$ORGANIZED_DIR"/rest/openRedirects "$ORGANIZED_DIR"/openRedirects.txt 2> /dev/null
    mv "$ORGANIZED_DIR"/rest/subTakeovers "$ORGANIZED_DIR"/subTakeovers.txt 2> /dev/null
 
    rm -rf "$ORGANIZED_DIR"/rest
    
# ------------

# Removing empty files and directories
    find "$ORGANIZED_DIR" -type f -empty -delete
    find "$ORGANIZED_DIR" -type d -empty -delete


    rm -rf "$TARGET_DIR/organised" 2> /dev/null
    mv -f "$TARGET_DIR/.organised" "$TARGET_DIR/organised"

# Mocing all target dirs to a centralised directory
    while IFS= read -r res; do
        mv "$TARGET_DIR"/$res "$TARGET_DIR"/all 2> /dev/null
    done < "$1"

}

usage() {
    echo "Usage: $0 <file.txt> <directory>"
    exit 1
}

# Check if the script has been called with the correct number of arguments
if [ $# -ne 2 ]; then
    usage
else
    main "$1" "$2"
fi