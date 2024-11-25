#!/bin/bash
#
# MIT License
#
# Copyright (c) 2024 github.com/mr-manuel
#
# Version: 0.0.1 (20241125)


# disable app
bash /data/apps/overlay-fs/disable.sh


read -r -p "Do you want to delete the app an all overlay data in \"/data/apps/overlay-fs\"? If you don't know just press enter. [y/N] " response
echo
response=${response,,} # tolower
if [[ $response =~ ^(y) ]]; then
    rm -rf /data/apps/overlay-fs
    echo "The folder \"/data/apps/overlay-fs\" was removed."
    echo
fi


echo "The overlay-fs app was uninstalled. Please reboot."
echo
