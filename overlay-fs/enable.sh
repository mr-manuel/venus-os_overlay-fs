#!/bin/bash
#
# MIT License
#
# Copyright (c) 2024 github.com/mr-manuel
#
# Version: 0.0.1 (20241118)


echo
echo "Installing overlay-fs app..."


# create overlay-fs and mount it, if not already mounted
function mountOverlayFs ()
{
    path="/data/apps/overlay-fs/data"
    lowerDir=$1

    # check if the path exists and is a directory
    if [ ! -d $lowerDir ]; then
        echo "$(date +%Y-%m-%d\ %H:%M:%S) ERROR: ${lowerDir} is not a directory"
        return 1
    fi

    if [ -z $2 ]; then
        # extract the top folder name of the path
        overlayName=$(basename $1)
    else
        overlayName=$2
    fi


    if [ ! -d "${path}/${overlayName}/upper" ]; then
        mkdir -p "${path}/${overlayName}/upper"
    fi
    if [ ! -d "${path}/${overlayName}/work" ]; then
        mkdir -p "${path}/${overlayName}/work"
    fi
    if [ ! -d "${path}/${overlayName}/merged" ]; then
        mkdir -p "${path}/${overlayName}/merged"
    fi


    # check if overlay is already mounted
    if ! mountpoint -q "${path}/${overlayName}/merged"; then
        echo "$(date +%Y-%m-%d\ %H:%M:%S) INFO: Mounting overlay for ${lowerDir}"
        # Mount the overlay
        # add "-o index=off" to avoid error when system had power loss:
        # mount: /data/apps/overlay-fs/gui-v2/merged: mount(2) system call failed: Stale file handle.
        # there is no difference for only a few changed files
        mount -t overlay OL_${overlayName} -o index=off -o lowerdir=${lowerDir},upperdir=${path}/${overlayName}/upper,workdir=${path}/${overlayName}/work ${path}/${overlayName}/merged

        # Check if the mount was successful
        if [ $? -ne 0 ]; then
            echo "$(date +%Y-%m-%d\ %H:%M:%S) ERROR: Could not mount overlay for ${lowerDir}"
            return 1
        fi
    fi


    # check if overlay is already mounted
    if ! mountpoint -q "${lowerDir}"; then
        echo "$(date +%Y-%m-%d\ %H:%M:%S) INFO: Mounting bind overlay for ${lowerDir}"
        # Mounting bind to the lower directory path
        mount --bind ${path}/${overlayName}/merged ${lowerDir}

        # Check if the mounting bind was successful
        if [ $? -ne 0 ]; then
            echo "$(date +%Y-%m-%d\ %H:%M:%S) ERROR: Could not mount bind overlay for ${lowerDir}"
            return 1
        fi
    fi
}



# fix permissions
chmod 755 /data/apps/overlay-fs/*.sh



# launch the overlay-fs at startup
filename=/data/rcS.local
# create the file if it doesn't exist
if [ ! -f "$filename" ]; then
    echo "$(date +%Y-%m-%d\ %H:%M:%S) INFO: rcS.local file doesn't exist. Creating it..."
    echo "#!/bin/bash" > "$filename"
    chmod 755 "$filename"
fi
# add the line to the 2nd line of the file if it doesn't exist
if ! grep -qxF "bash /data/apps/overlay-fs/enable.sh > /data/apps/overlay-fs/startup.log 2>&1" "$filename"; then
    echo "$(date +%Y-%m-%d\ %H:%M:%S) INFO: Adding overlay-fs startup command to rcS.local"
    sed -i '2i bash /data/apps/overlay-fs/enable.sh > /data/apps/overlay-fs/startup.log 2>&1' "$filename"
fi


# Read the config file and loop through each line
while IFS= read -r line; do
    # Ensure the line starts with /
    if [[ $line =~ ^\/ ]]; then
        mountOverlayFs $line
    fi
done < /data/apps/overlay-fs/overlay-fs.conf

echo "done."
echo
