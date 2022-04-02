#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root, i.e. sudo $0"
    exit 1
fi

cp ./auto-connect-hotspot.sh /Library/Scripts/
chmod 755 /Library/Scripts/auto-connect-hotspot.sh
cp ./com.nick.auto-connect-hotspot.plist /Library/LaunchAgents/
chmod 600 /Library/LaunchAgents/com.nick.auto-connect-hotspot.plist
launchctl load /Library/LaunchAgents/com.nick.auto-connect-hotspot.plist
