# Auto HotSpot

## About

Automatically Connect Mac to personal hotspot if no more preferred network available, based on network change. i.e. turn on/off wifi, connected/disconnected to a network, etc.

## Requirement

* Elevated privilege to install the daemon
* Grant *Access Control* permission to `/usr/bin/security` of the hotspot ssid in *Keychain Access*
* Password for the hotspot has been saved to *keychain*

## Usage

### Install

1. *Grant*Access Control*permission to `/usr/bin/security` of the hotspot ssid in*Keychain Access*
    1. Open *Keychain Access*
    2. Select *All items* tab
    3. Input the SSID of your hotspot in the search box and search
    4. Select the record with of your SSID name with *System* in *Keychain* column and double click
    5. Choose *Access Control* tab
    6. Click + and input the path to security `/usr/bin` (keyboard shortcut: `command shift g`)
    7. select *security* and *Add*
2. clone the repo
3. Modify the `ProgramArguments` key in plist file to your need
    * The first arg is the program itself, DON'T modify
    * The second arg is the SSID of your hotspot
    * The third arg is the maximum time duration to run this script when network change occurs and not yet connected to hotspot
    * The fourth arg is the trigger SSID that if present in available Wifis or unspecified then connect to hotspot, otherwise do nothing.
4. `sudo ./install.sh`

### Uninstall

`sudo ./uninstall.sh`

## Credit

* <https://gist.github.com/albertbori/1798d88a93175b9da00b>
* <https://github.com/paulbhart/toggleairport>
