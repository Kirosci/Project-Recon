#!/bin/bash

main() {
    while IFS= read -r res; do
        mkdir -p "$2" || { echo "Failed to create directory '$2'"; }
        cp -r "results/$res" "$2" || { echo "Failed to move '$res' to '$2'"; }
    done < "$1"

    TARGET_DIR="$2"

    # Create the 'organized' folder in the main directory if it doesn't exist
    ORGANIZED_FOLDER="${TARGET_DIR}/organized"
    mkdir -p "$ORGANIZED_FOLDER"

    echo "Moving files from directories in $TARGET_DIR to $ORGANIZED_FOLDER..."

    # Move all files to the 'organized' folder
    find "$TARGET_DIR" -type f -name *.txt -not -path '*/\.*' -exec cp -r {} "$ORGANIZED_FOLDER" \;

    echo "Sorting and combining files in $ORGANIZED_FOLDER..."

    # Sort and combine files
    cd "$ORGANIZED_FOLDER"
    ls | while read -r file; do
        # Skip if the file is already sorted and combined
        if [[ "$file" == *"combined"* ]]; then
            continue
        fi
        
        # Find all files with the same base name
        matching_files=$(ls | grep "^${file%.*}")
        
        if [ ${#matching_files[@]} -gt 1 ]; then
            # Read, sort, and write to a combined file
            cat "${matching_files[@]}" | sort > "${file%.*}combined.txt"
            
            echo "Combined '${file}' into '${file%.*}combined.txt'"
        else
            echo "No matching files for '${file}', skipping..."
        fi
    done

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



# ----------------------------------------------------------------
# #!/bin/bash

# # Check if the first argument is provided
# if [ $# -lt 1 ]; then
#     echo "Usage: $0 <directory>"
#     exit 1
# fi

# TARGET_DIR="$1"

# # Create the 'organized' folder in the main directory if it doesn't exist
# ORGANIZED_FOLDER="${TARGET_DIR}/organized"
# mkdir -p "$ORGANIZED_FOLDER"

# echo "Moving files from directories in $TARGET_DIR to $ORGANIZED_FOLDER..."

# # Move all files to the 'organized' folder
# find "$TARGET_DIR" -type f -name *.txt -not -path '*/\.*' -exec mv {} "$ORGANIZED_FOLDER" \;

# echo "Sorting and combining files in $ORGANIZED_FOLDER..."

# # Sort and combine files
# cd "$ORGANIZED_FOLDER"
# ls | while read -r file; do
#     # Skip if the file is already sorted and combined
#     if [[ "$file" == *"combined"* ]]; then
#         continue
#     fi
    
#     # Find all files with the same base name
#     matching_files=$(ls | grep "^${file%.*}")
    
#     if [ ${#matching_files[@]} -gt 1 ]; then
#         # Read, sort, and write to a combined file
#         cat "${matching_files[@]}" | sort > "${file%.*}combined.txt"
        
#         echo "Combined '${file}' into '${file%.*}combined.txt'"
#     else
#         echo "No matching files for '${file}', skipping..."
#     fi
# done
# ----------------------------------------------------------------
