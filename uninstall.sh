#!/bin/bash
#git@github.com:paulbhart/toggleairport.git
#originally from https://gist.github.com/albertbori/1798d88a93175b9da00b
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root, i.e. sudo $0"
    exit 1
fi

rm /Library/Scripts/toggleAirport.sh
rm  /Library/LaunchAgents/com.mine.toggleairport.plist
launchctl unload /Library/LaunchAgents/com.mine.toggleairport.plist