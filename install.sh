#!/bin/bash

########### Colors ############
readonly RED="31m"
readonly GREEN="32m"
readonly YELLOW="33m"
readonly BLUE="36m"

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root, i.e. sudo $0"
    exit 1
fi

cp ./auto-connect-hotspot.sh /Library/Scripts/
chmod 755 /Library/Scripts/auto-connect-hotspot.sh
cp ./com.nick.auto-connect-hotspot.plist /Library/LaunchAgents/
chmod 600 /Library/LaunchAgents/com.nick.auto-connect-hotspot.plist
launchctl bootstrap system /Library/LaunchAgents/com.nick.auto-connect-hotspot.plist

export LANG=en_US.UTF-8

color_print() {
    echo -e "\033[${1}${@:2}\033[0m" 1>&2
}

help() {

    cat - 1>&2 <<EOF
auto-connect-hotspot.sh [-h] [-t trigger] [--remove] [-s hotspot] [-d seconds] [--version]
  -h, --help            Show help
  -t, --trigger_ssid    Specify the trigger ssid.
                            When this network is around, try to connect to your
                            personal hotspot
                            If not specified, connect to your hotspot whenever network changes
  -s, --hotspot         The personal hotspot ssid to try to connect to
  -v  --version         The version of this script
  -d, --duration        Maximum time duration in seconds to try
                        when trigger conditions
                        are met and not yet connected to hotspot
      --remove          Remove installed daemon

============== EXAMPLES ==========================



EOF
}

main() {

}
