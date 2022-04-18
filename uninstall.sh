#!/bin/bash
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root, i.e. sudo $0"
    exit 1
fi

launchctl bootout system /Library/LaunchAgents/com.nick.auto-hotspot.plist
rm /Library/Scripts/auto-hotspot.sh
rm /Library/LaunchAgents/com.nick.auto-hotspot.plist
