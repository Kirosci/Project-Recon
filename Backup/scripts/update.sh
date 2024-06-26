#!/bin/bash

REPO_PATH="$(dirname "$(realpath "$0")")"
BRANCH="main"


update_repo() {
    echo "Updating the repository..."
    cd $REPO_PATH || { echo "Failed to change directory to $REPO_PATH"; exit 1; }
    git fetch origin $BRANCH || { echo "Failed to fetch updates from the remote repository"; exit 1; }
    git reset --hard origin/$BRANCH || { echo "Failed to reset the local repository"; exit 1; }
    echo "Repository updated successfully."
}

update_repo