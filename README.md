# Auto Connect HotSpot

## About

Automatically Connect to personal hotspot based on network SSID change

## Usage

### Install

1. Give permission to `/usr/bin/security` the ssid of the hotspot you want to connect at *Keychain Access* -> *ssid* -> *Get Info* -> *Access Control*
2. clone the repo
3. Modify the `ProgramArguments` key in plist file to your need
    * The first arg is the program itself, DON'T modify
    * The second arg is the trigger SSID that if present connect to hotspot, otherwise do nothing. If empty then won't check
    * The third arg is the SSID of your hotspot
    * The fourth arg is the maximum time duration to run this script when network change occurs and not yet connected to hotspot
4. `sudo ./install.sh`

### Uninstall

`sudo ./uninstall.sh`

## Requirement

* Give permission to `/usr/bin/security` the ssid of the hotspot you want to connect at *Keychain Access* -> *ssid* -> *Get Info* -> *Access Control*

## Credit

<https://gist.github.com/albertbori/1798d88a93175b9da00b>
<https://github.com/paulbhart/toggleairport>
