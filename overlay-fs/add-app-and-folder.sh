#!/bin/bash
#
# MIT License
#
# Copyright (c) 2024 github.com/mr-manuel
#
# Version: 0.0.1 (20241125)

# This script adds a folder to the overlay-fs.
# It checks if the folder or any of its parent folders are already in the config file.
# If so, it will not add the folder but will add the app name to the existing entry.
#
# Usage: add-app-and-folder.sh <folder> <app-name>


checkOverlayRecursive() {
    local dir="$1"
    while [ "$dir" != "/" ]; do
        if mount | grep -q "on $dir type overlay"; then
            echo "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    return 1
}

checkConfigRecursive() {
    local dir="$1"
    while [ "$dir" != "/" ]; do
        if grep -q "^$dir " /data/apps/overlay-fs/overlay-fs.conf; then
            # Output the whole line and not only the directory
            grep "^$dir " /data/apps/overlay-fs/overlay-fs.conf
            return 0
        fi
        dir=$(dirname "$dir")
    done
    return 1
}


# Get command line arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <folder> <app-name>"
    exit 1
fi

# Remove trailing slash from folder
if [ "${1: -1}" == "/" ]; then
    folder="${1%/}"
else
    folder="$1"
fi

# Check if the folder exists
if [ ! -d "$folder" ]; then
    echo "The folder \"$folder\" does not exist."
    exit 1
fi

# Check if the path is a symlink
if [ -L "$folder" ]; then
    echo "The folder \"${folder}\" is a symlink and cannot be used."
    exit 1
fi


# Check if the folder is already mounted as an overlay and if the folder exists in the config file
# overlayDir=$(checkOverlayRecursive "$folder")
# if [ $? -eq 0 ]; then
#     echo "The folder \"$folder\" cannot be enabled, since \"$overlayDir\" is already mounted as an overlay-fs."
#     exit 1
# fi


# Check if the folder exists in the config file
configEntry="$(checkConfigRecursive "$folder")"
if [ $? -eq 0 ]; then
    # Split the config entry on the first space
    IFS=' ' read -r configDir appNames other <<< "$configEntry"

    # Split the app names on the comma
    IFS=',' read -ra appNamesArray <<< "$appNames"

    # Check if the app name is already in the entry
    for app in "${appNamesArray[@]}"; do
        if [ "$app" == "$2" ]; then
            echo "The app \"$2\" was already added to the folder \"$configDir\" in the config file."
            exit 1
        fi
    done

    # Add the app name to the existing entry
    sed -i "s|^$configDir .*|&,$2|" /data/apps/overlay-fs/overlay-fs.conf
    echo "The app \"$2\" was added to the folder \"$configDir\" in the config file."
else
    # Add the folder to the config file
    echo "$folder $2" >> /data/apps/overlay-fs/overlay-fs.conf
    echo "The folder \"$folder\" was added to the config file."

    # Run enable.sh to mount the overlay-fs
    echo "Execute enable.sh to mount the overlay-fs."
    /data/apps/overlay-fs/enable.sh
fi
