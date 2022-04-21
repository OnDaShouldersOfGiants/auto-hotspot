#!/bin/bash
###
# @Author: Nick Liu
# @Date: 2022-03-22 10:53:09
# @LastEditTime: 2022-04-21 16:03:15
# @LastEditors: Nick Liu
# @Description: Audo connect Mac to hotspot with supplied command line args as config
# @FilePath: /init-network-per-net-change-mac/auto-hotspot.sh
###

function notify() {
    osascript -e 'display notification "Connected to hotspot "' \
        "$1"'" with title "Connected"'
}

function is_connected() {
    # if connected to cable ethernet
    for eth_name in $1; do
        if ifconfig "$eth_name" | grep -q 'status: active'; then
            true
        fi
    done

    # if connecteed to wifi
    if /usr/sbin/networksetup -getairportnetwork "$2" | grep -q 'You are not associated with an AirPort network.'; then
        false
    else
        true
    fi
}

# get the password for passed-in item
function get_pw() {
    security find-generic-password -ga "$1" 2>&1 >/dev/null | grep "password: " | sed -e "s/^password: \"//" -e "s/\"$//"
}

function try_connect() {
    start_time_stamp=$SECONDS
    while ! is_connected "$4" "$5" && ((SECONDS - start_time_stamp < $3)); do
        # if to check trigger ssid and trigger ssid is not present
        if "$6" && ! /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s | awk '{print $1}' | tail -n+2 | grep -q "$1"; then
            return
        fi
        networksetup -setairportnetwork "$5" "$2" "$(get_pw "$2")"
        sleep 4
    done
}

function main() {
    hotspot_ssid="$1"
    # the trigger ssid that allow this script to keep trying to connect to hotspot if present
    trigger_ssid="$2"
    max_retry_duration="$3"
    check_trigger_ssid=true
    if [ -z "$trigger_ssid" ]; then
        check_trigger_ssid=false
    fi

    # names of the network services
    eth_names=$(networksetup -listnetworkserviceorder | sed -En 's/^\(Hardware Port: .*(Ethernet|LAN).* Device: (en[0-9]+)\)$/\2/p')
    air_name=$(networksetup -listnetworkserviceorder | sed -En 's/^\(Hardware Port: (Wi-Fi|AirPort).* Device: (en[0-9]+)\)$/\2/p')

    if is_connected "$eth_names" "$air_name"; then
        return 0
    fi

    try_connect "$trigger_ssid" "$hotspot_ssid" "$max_retry_duration" "$eth_name" "$air_name" "$check_trigger_ssid"
    if /usr/sbin/networksetup -getairportnetwork "$air_name" | awk '{ print $4 }' | grep -q 'ip'; then
        notify "$hotspot_ssid"
    fi
}

main "$@"
