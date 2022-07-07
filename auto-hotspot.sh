#!/bin/bash
###
# @Author: Nick Liu
# @Date: 2022-03-22 10:53:09
# @LastEditTime: 2022-07-07 05:45:53
# @LastEditors: Nick Liu
# @Description: Audo connect Mac to hotspot with supplied command line args as config
# @FilePath: /init-network-per-net-change-mac/auto-hotspot.sh
###

trap -- '' SIGINT SIGTERM

function notify() {
    launchctl asuser "$2" osascript -e "display notification \"Connected to hotspot $1\" with title \"Network Connected\""
}

# fix tests
function is_connected() {
    # if connected to cable ethernet
    for eth_name in $1; do
        if ifconfig "$eth_name" | grep -q 'status: active'; then
            true
            return
        fi
    done

    # if connecteed to wifi
    if /usr/sbin/networksetup -getairportnetwork "$2" | grep -q 'You are not associated with an AirPort network.'; then
        false
        return
    else
        true
        return
    fi
}

# get the password for passed-in item
function get_pw() {
    security find-generic-password -ga "$1" 2>&1 >/dev/null | grep "password: " | sed -e "s/^password: \"//" -e "s/\"$//"
}

function try_connect() {
    start_time_stamp=$SECONDS
    prev_connected=false
    connected_by_script=false
    while ((SECONDS - start_time_stamp < $3)) || prev_connected; do
        # make sure connected for at least 10 seconds
        if is_connected "$4" "$5"; then
            if $prev_connected; then
                $connected_by_script
                return
            fi
            prev_connected=true
            sleep 10
            continue
        else
            prev_connected=false
        fi
        # if to check trigger ssid and trigger ssid is not present
        if "$6" && ! /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s | awk '{print $1}' | tail -n+2 | grep -q "$1"; then
            false
            return
        fi
        if networksetup -setairportnetwork "$5" "$2" "$(get_pw "$2")" -eq 0; then
            connected_by_script=true
        else
            sleep 4
        fi
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

    if try_connect "$trigger_ssid" "$hotspot_ssid" "$max_retry_duration" "$eth_names" "$air_name" "$check_trigger_ssid"; then
        notify "$hotspot_ssid" "$4"
    fi
}

main "$@"
