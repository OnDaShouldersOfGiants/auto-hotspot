#!/bin/bash
#git@github.com:paulbhart/toggleairport.git
#originally from https://gist.github.com/albertbori/1798d88a93175b9da00b
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root, i.e. sudo $0"
    exit 1
fi

cp ./toggleAirport.sh /Library/Scripts/
chmod 755 /Library/Scripts/toggleAirport.sh
cp ./com.mine.toggleairport.plist /Library/LaunchAgents/
chmod 600 /Library/LaunchAgents/com.mine.toggleairport.plist
launchctl load /Library/LaunchAgents/com.mine.toggleairport.plist
