#!/bin/bash

# Default values
THREADS=50
RETRY=3
TIMEOUT=10

# Function to display usage
usage() {
    echo "Usage: $0 -f <filename> [-t <threads>] [-r <retry>] [-x <timeout>]"
    exit 1
}

# Parse command line options
while getopts ":f:t:r:x:" opt; do
    case $opt in
        f)
            FILENAME=$OPTARG
            ;;
        t)
            THREADS=$OPTARG
            ;;
        r)
            RETRY=$OPTARG
            ;;
        x)
            TIMEOUT=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            usage
            ;;
    esac
done

# Check if filename is provided
if [ -z "$FILENAME" ]; then
    echo "Error: Please provide a filename using -f option."
    usage
fi

# Create directory if not exists
mkdir -p jsSource

# Initialize linked.txt
echo -n > linked.txt

# Function to download a file
download_file() {
    url=$1
    index=$2
    filename="jsSource/${index}.js"

    # Retry loop
    for ((i=1; i<=$RETRY; i++)); do
        wget --timeout=$TIMEOUT -O $filename $url && echo "$url : ${index}.js" >> linked.txt && break
        sleep 1
    done
}

# Read URLs from file and download in parallel
index=1
cat $FILENAME | while read -r url; do
    ((index++))
    download_file "$url" "$index" &
    ((index % THREADS == 0)) && wait
done

# Wait for any remaining background processes
wait

echo "Download completed."
