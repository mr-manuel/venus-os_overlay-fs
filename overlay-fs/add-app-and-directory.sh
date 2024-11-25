#!/bin/bash
#
# MIT License
#
# Copyright (c) 2024 github.com/mr-manuel
#
# Version: 0.0.1 (20241125)

# This script adds a directory to the overlay-fs.
# It checks if the directory or any of its parent directorys are already in the config file.
# If so, it will not add the directory but will add the app name to the existing entry.
#
# Usage: add-app-and-directory.sh <app-name> <directory-path>


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
    echo "Usage: $0 <app-name> <directory-path>"
    exit 1
fi

appNameArg="$1"

# Remove trailing slash from directory
if [ "${2: -1}" == "/" ]; then
    directory="${2%/}"
else
    directory="$2"
fi

# Check if the directory exists
if [ ! -d "$directory" ]; then
    echo "The directory \"$directory\" does not exist."
    exit 1
fi

# Check if the path is a symlink
if [ -L "$directory" ]; then
    echo "The directory \"${directory}\" is a symlink and cannot be used."
    exit 1
fi


# Check if the directory is already mounted as an overlay and if the directory exists in the config file
# overlayDir=$(checkOverlayRecursive "$directory")
# if [ $? -eq 0 ]; then
#     echo "The directory \"$directory\" cannot be enabled, since \"$overlayDir\" is already mounted as an overlay-fs."
#     exit 1
# fi


# Check if the directory exists in the config file
configEntry="$(checkConfigRecursive "$directory")"
if [ $? -eq 0 ]; then
    # Split the config entry on the first space
    IFS=' ' read -r configDir appNames other <<< "$configEntry"

    # Split the app names on the comma
    IFS=',' read -ra appNamesArray <<< "$appNames"

    # Check if the app name is already in the entry
    for app in "${appNamesArray[@]}"; do
        if [ "$app" == "$appNameArg" ]; then
            echo "The app \"$appNameArg\" was already added to the directory \"$configDir\" in the config file."
            exit 1
        fi
    done

    # Add the app name to the existing entry
    sed -i "s|^$configDir .*|&,$appNameArg|" /data/apps/overlay-fs/overlay-fs.conf
    echo "The app \"$appNameArg\" was added to the directory \"$configDir\" in the config file."
else
    # Add the directory to the config file
    echo "$directory $appNameArg" >> /data/apps/overlay-fs/overlay-fs.conf
    echo "The directory \"$directory\" was added to the config file."
    echo

    # Run enable.sh to mount the overlay-fs
    echo "Execute enable.sh to mount the overlay-fs."
    /data/apps/overlay-fs/enable.sh
fi
