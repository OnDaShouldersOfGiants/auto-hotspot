#!/bin/bash
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root, i.e. sudo $0"
    exit 1
fi

rm /Library/Scripts/auto-connect-hotspot.sh
rm /Library/LaunchAgents/com.nick.auto-connect-hotspot.plist
launchctl unload /Library/LaunchAgents/com.nick.auto-connect-hotspot.plist
