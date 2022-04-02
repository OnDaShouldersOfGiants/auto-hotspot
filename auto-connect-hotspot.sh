#!/usr/bin/env bash

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
    while ! is_connected "$4" "$5" && ((SECONDS - start_time_stamp < 600)) && /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s | awk '{print $1}' | tail -n+2 | grep -q "$1"; do
        networksetup -setairportnetwork "$5" "$2" "$(get_pw "$2")"
        sleep "$3"
    done
}

function main() {
    # the trigger ssid that allow this script to keep trying to connect to hotspot if present
    trigger_to_connect_ssid="$1"
    hotspot_to_connect_ssid="$2"
    sleep_interval="$3"

    # names of the network services
    eth_names=$(networksetup -listnetworkserviceorder | sed -En 's/^\(Hardware Port: .*(Ethernet|LAN).* Device: (en[0-9]+)\)$/\2/p')
    air_name=$(networksetup -listnetworkserviceorder | sed -En 's/^\(Hardware Port: (Wi-Fi|AirPort).* Device: (en[0-9]+)\)$/\2/p')

    if is_connected "$eth_names" "$air_name"; then
        return 0
    fi

    try_connect "$trigger_to_connect_ssid" "$hotspot_to_connect_ssid" "$sleep_interval" "$eth_name" "$air_name"
    if /usr/sbin/networksetup -getairportnetwork "$air_name" | awk '{ print $4 }' | grep -q 'ip'; then
        notify "$hotspot_to_connect_ssid"
    fi
}

main "$@"
