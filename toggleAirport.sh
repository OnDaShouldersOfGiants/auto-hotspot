#!/bin/bash
set -x
function set_airport {

    new_status=$1

    if [ $new_status = "On" ]; then
        /usr/sbin/networksetup -setairportpower $air_name on
        touch /var/tmp/prev_air_on
    else
        /usr/sbin/networksetup -setairportpower $air_name off
        if [ -f "/var/tmp/prev_air_on" ]; then
            rm /var/tmp/prev_air_on
        fi
    fi

}

function growl {

    # Checks whether Growl is installed
    if [ -f "/usr/local/bin/growlnotify" ]; then
        /usr/local/bin/growlnotify -m "$1" -a "AirPort Utility.app"
    else
        osascript -e "display notification \"$1\" with title \"Wifi Toggle\" sound name \"Hero\""
    fi

}

# Set default values
prev_eth_status="Off"
prev_air_status="Off"
eth_status="Off"

# Grab the names of the adapters. We assume here that any ethernet connection name ends in "Ethernet"
eth_names=`networksetup -listnetworkserviceorder | sed -En 's|^\(Hardware Port: .*Ethernet, Device: (en.)\)$|\1|p'`
air_name=`networksetup -listnetworkserviceorder | sed -En 's/^\(Hardware Port: (Wi-Fi|AirPort), Device: (en.)\)$/\2/p'`

# Determine previous ethernet status
# If file prev_eth_on exists, ethernet was active last time we checked
if [ -f "/var/tmp/prev_eth_on" ]; then
    prev_eth_status="On"
fi

# Determine same for AirPort status
# File is prev_air_on
if [ -f "/var/tmp/prev_air_on" ]; then
    prev_air_status="On"
fi

# Check actual current ethernet status
for eth_name in ${eth_names}; do
    if ([ "$eth_name" != "" ] && [ "`ifconfig $eth_name | grep "status: active"`" != "" ]); then
        eth_status="On"
    fi
done

# And actual current AirPort status
air_status=`/usr/sbin/networksetup -getairportpower $air_name | awk '{ print $4 }'`

# If any change has occured. Run external script (if it exists)
if [ "$prev_air_status" != "$air_status" ] || [ "$prev_eth_status" != "$eth_status" ]; then
    if [ -f "./statusChanged.sh" ]; then
        "./statusChanged.sh" "$eth_status" "$air_status" &
    fi
fi

# Determine whether ethernet status changed
if [ "$prev_eth_status" != "$eth_status" ]; then

    if [ "$eth_status" = "On" ]; then
        set_airport "Off"
        growl "Wired network detected. Turning AirPort off."
    else
        set_airport "On"
        growl "No wired network detected. Turning AirPort on."
    fi

# If ethernet did not change
else

    # Check whether AirPort status changed
    # If so it was done manually by user
    if [ "$prev_air_status" != "$air_status" ]; then
    set_airport $air_status

    if [ "$air_status" = "On" ]; then
        growl "AirPort manually turned on."
    else
        growl "AirPort manually turned off."
    fi

    fi

fi

# Update ethernet status
if [ "$eth_status" == "On" ]; then
    touch /var/tmp/prev_eth_on
else
    if [ -f "/var/tmp/prev_eth_on" ]; then
        rm /var/tmp/prev_eth_on
    fi
fi

exit 0
