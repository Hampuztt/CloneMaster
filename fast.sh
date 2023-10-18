#!/bin/bash

# Extract the URL from the clipboard
REPO_URL=$(xclip -selection clipboard -o)

# Determine the type of the GitLab URL (commit, branch, commits list, or none)
# and extract the base URL and the reference (commit hash or branch name)

# Match a commit URL pattern
if [[ $REPO_URL =~ ^(https://gitlab\..+/[^/]+/[^/]+)/-/commit/([a-f0-9]{40})$ ]]; then

    BASE_URL="${BASH_REMATCH[1]}.git"
    REF="${BASH_REMATCH[2]}"

# Match a branch URL pattern
elif [[ $REPO_URL =~ ^(https://gitlab\..+/[^/]+/[^/]+)/-/tree/([^/?]+) ]]; then
    BASE_URL="${BASH_REMATCH[1]}.git"
    REF="${BASH_REMATCH[2]}"

# Match a commits list URL pattern
elif [[ $REPO_URL =~ ^(https://gitlab\..+/[^/]+/[^/]+)/-/commits/([^/?]+) ]]; then
    BASE_URL="${BASH_REMATCH[1]}.git"
    REF="${BASH_REMATCH[2]}"

# Default: Assume the clipboard content is a direct repository URL
else
    BASE_URL=$REPO_URL
    REF=""
fi


# Validate that the extracted base URL is a valid Git repository URL
if [[ ! ($BASE_URL =~ ^https://gitlab.* || $BASE_URL =~ .*.git$) ]]; then
    echo "Error: The clipboard content is $BASE_URL and dosen't look like a git repository URL!"
    exit 1
fi


# Prompt the user for a keyword to search for a specific Qt project file
echo "Enter .pro file to open"
echo "Labb 1 - life"
echo "Labb 2 - wordchain, evilhangman"
echo "Labb 3 - tsp"
echo "Labb 4 - robots"
echo "Labb 5 - boggle"
echo "Labb 6 - fisher"  
echo "Labb 7 - patternrecognition"
echo "Labb 8 - trailblazer" 

read -p ": " SEARCH_KEYWORD

# Remove any previously cloned repository (specific to the script's context)
#rm -rf tddd86-*

# Clone the repository using the extracted base URL
# Determine unique folder name
OWNER_NAME=$(echo $BASE_URL | sed -r 's#https://gitlab\.([^/]+)/([^/]+)/.*#\2#')
DIR_NAME=$(basename $BASE_URL .git)
UNIQUE_DIR_NAME="${OWNER_NAME}-${DIR_NAME}"



# Check if the repository already exists locally
if [ -d "$UNIQUE_DIR_NAME" ]; then
    cd $UNIQUE_DIR_NAME
    git pull
    if [ ! -z "$REF" ]; then
        git checkout $REF
    fi
    cd ..
else
    git clone $BASE_URL ${REF:+--branch $REF} $UNIQUE_DIR_NAME || { echo "Error: Git clone failed"; exit 1; }
fi
# Determine the directory name of the cloned repository
#DIR_NAME=$(basename $BASE_URL .git)

# Find the Qt project file (.pro) with the specified keyword in the cloned repository
FILE_PATH=$(find $UNIQUE_DIR_NAME -type f -iname "${SEARCH_KEYWORD}.pro")

#echo "FILE_PATH: $FILE_PATH $UNIQUE_DIR_NAME"

# If the Qt project file is found, open it with Qt Creator; else, display an error
if [ ! -z "$FILE_PATH" ]; then
    qtcreator $FILE_PATH
else
    echo "Error: ${SEARCH_KEYWORD}.pro not found in the cloned repository!"
    exit 1
fi
