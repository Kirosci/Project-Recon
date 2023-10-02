#!/bin/bash

# Function to display a spinning bar
function loading() {
    local chars="/-\|"
    while :; do
        for ((i=0; i<${#chars}; i++)); do
            echo -ne "${chars:$i:1}\r"
            sleep 0.1
        done
    done
}

# Start the loading animation in the background
loading &

# Simulate some work
sleep 5

# Stop the loading animation by killing the background process
kill $!

# Clear the line
echo -e "\033[2K\033[1GDone"
