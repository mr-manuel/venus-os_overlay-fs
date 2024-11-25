#!/bin/bash
#
# MIT License
#
# Copyright (c) 2024 github.com/mr-manuel
#
# Version: 0.0.1 (20241125)

# This script checks if a folder is mounted on an overlay filesystem (overlay-fs).
# It returns 0 if the folder is mounted on an overlay-fs, and 1 if it is not.
#
# Usage: check-folder.sh <folder>


# Get command line arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <folder>"
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

# Check if the folder is mounted on an overlay-fs
if mount | grep -q "on $folder type overlay"; then
    echo "The folder \"$folder\" is mounted on an overlay-fs."
    exit 0
else
    echo "The folder \"$folder\" is not mounted on an overlay-fs."
    exit 1
fi
