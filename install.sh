#!/bin/bash
#
# MIT License
#
# Copyright (c) 2024 github.com/mr-manuel
#
# INFO
# use this script to install the latest version of the app and copy it to the correct location
#
# COMMAND LINE ARGUMENTS
# -c, --copy: copy the app to the correct location if delivered as dependency without downloading


app_path="/data/apps"
app_name="overlay-fs"

# change to temp folder
cd /tmp

echo


# check command line arguments
if [ "$1" == "-c" ] || [ "$1" == "--copy" ]; then

    echo "Copying app..."

    # check if the app folder is available
    if [ ! -d "overlay-fs" ]; then
        echo "The app folder is not available. Try to execute the download script to install, else copy the files again."
        exit 1
    fi

    # get the path of this script
    source_path=$(dirname $(realpath $0))/overlay-fs/


else

    # download app
    echo "Downloading app..."


    # download nightly build
    url="https://github.com/mr-manuel/venus-os_${app_name}/archive/refs/heads/master.zip"

    echo "Downloading from: $url"
    wget -O /tmp/venus-os_${app_name}.zip "$url"

    # check if download was successful
    if [ ! -f /tmp/venus-os_${app_name}.zip ]; then
        echo
        echo "Download failed. Exiting..."
        exit 1
    fi


    # If updating: cleanup old folder
    if [ -d /tmp/venus-os_${app_name}-master ]; then
        rm -rf /tmp/venus-os_${app_name}-master
    fi


    # unzip folder
    echo "Unzipping app..."
    unzip venus-os_${app_name}.zip

    # Find and rename the extracted folder to be always the same
    extracted_folder=$(find /tmp/ -maxdepth 1 -type d -name "*${app_name}-*")

    # Desired folder name
    desired_folder="/tmp/venus-os_${app_name}-master"

    # Check if the extracted folder exists and does not already have the desired name
    if [ -n "$extracted_folder" ]; then
        if [ "$extracted_folder" != "$desired_folder" ]; then
            mv "$extracted_folder" "$desired_folder"
        else
            echo "Folder already has the desired name: $desired_folder"
        fi
    else
        echo "Error: Could not find extracted folder. Exiting..."
        # exit 1
    fi

    source_path=/tmp/venus-os_${app_name}-master/${app_name}/

fi


# If updating: backup existing config file
if [ -f ${app_path}/${app_name}/overlay-fs.conf ]; then
    echo
    echo "Backing up existing config file..."
    mv ${app_path}/${app_name}/overlay-fs.conf ${app_path}/${app_name}_overlay-fs.conf
fi


# If updating: cleanup existing app
if [ -d ${app_path}/${app_name} ]; then
    echo
    echo "Cleaning up existing app..."
    rm -rf ${app_path:?}/${app_name}
fi


# copy files
echo
echo "Copying new app files..."
if [ ! -d ${app_path} ]; then
    mkdir -p ${app_path}
fi
cp -R ${source_path} ${app_path}/${app_name}/

# remove temp files

echo
echo "Cleaning up temp files..."
if [ -f /tmp/venus-os_${app_name}.zip ]; then
    rm -rf /tmp/venus-os_${app_name}.zip
fi
if [ -d /tmp/venus-os_${app_name}-master ]; then
    rm -rf /tmp/venus-os_${app_name}-master
fi


# If updating: restore existing config file
if [ -f ${app_path}/${app_name}_overlay-fs.conf ]; then
    echo
    echo "Restoring existing config file..."
    if [ -f ${app_path}/${app_name}/overlay-fs.conf ]; then
        rm ${app_path}/${app_name}/overlay-fs.conf
    fi
    mv ${app_path}/${app_name}_overlay-fs.conf ${app_path}/${app_name}/overlay-fs.conf
fi


# set permissions for files
echo
echo "Setting permissions for files..."
chmod 755 ${app_path}/${app_name}/*.sh


# copy default config file
if [ ! -f ${app_path}/${app_name}/overlay-fs.conf ]; then
    echo
    echo
    echo "First installation detected. Copying default config file..."
    echo
    echo "** Do not forget to edit the config file with your settings! **"
    echo "You can edit the config file with the following command:"
    echo "nano ${app_path}/${app_name}/overlay-fs.conf"
    cp ${app_path}/${app_name}/overlay-fs.conf.sample ${app_path}/${app_name}/overlay-fs.conf
    echo
    echo "** Execute the enable.sh script after you have edited the config file! **"
    echo "You can execute the enable.sh script with the following command:"
    echo "bash ${app_path}/${app_name}/enable.sh"
    echo
else
    echo
    echo "Reboot to apply new version..."
fi


echo
echo "Done."
echo
echo
