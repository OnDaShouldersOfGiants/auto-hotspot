#!/bin/bash
###
# @Author: Nick Liu
# @Date: 2022-03-22 10:53:09
# @LastEditTime: 2022-07-02 11:25:16
# @LastEditors: Nick Liu
# @Description: the utility script for installation/uninstallation and help menu
# @FilePath: /init-network-per-net-change-mac/install.sh
###

########### Formats     ############

readonly RED="31"
readonly GREEN="32"
readonly YELLOW="33"
readonly BLUE="34"
readonly BOLD="1"
readonly NORMAL="0"
readonly BLACK="30"

########### Menu flags  ############
# first element for getopts
# second element is short option
# third element is long option
readonly HELP_FLAG=("h" "help" "h")
readonly VERSION_FLAG=("v" "version" "v")
readonly HOTSPOT_SSID_FLAG=("s" "hotspot_ssid" "s:" "hotspot_ssid")
readonly TRIGGER_SSID_FLAG=("t" "trigger_ssid" "t:" "trigger_ssid")
readonly RETRY_DURATION_FLAG=("d" "retry_duration" "d:" "retry_duration")
readonly INSTALL_FLAG=("i" "install" "i")
readonly UNINSTALL_FLAG=("u" "uninstall" "u")

# print line
# first param: false: no-op
#              true: empty line
#              otherwise: treat first and the rest params as printf params
fmt_println() {
    flag_start_idx=1
    num_flags=$#-1
    if [[ "$1" == "false" ]]; then
        # no-op
        return
    elif [[ "$1" == "true" ]]; then
        # empty line
        if ((num_flags == 0)); then
            printf "\n"
            return
        fi
        flag_start_idx=2
        ((num_flags -= 1))
    fi

    str=${*:$#} # last arg
    old_ifs="$IFS"
    IFS=';'
    # everything but last arg(and first param when it's true/false)
    flags="'${*:$flag_start_idx:$num_flags}'"
    IFS=$old_ifs
    printf "\e[${flags}m%s\e[m\n" "$str"
}

indent() {
    pr -to "$1"
}

is_in() {
    local es match="$1"
    shift
    for es; do [[ "$es" == "$match" ]] && return 0; done
    return 1
}

version() {
    fmt_println "ver"
}

# TODO: colorful required and optional flag, colorful default/unspecified
# TODO: refactor println with print block
help() {
    # whether to display usage only or full help
    is_short=$([ "$3" == "USAGE" ] && echo "false" || echo "true")
    is_bold_flags=$([ "$3" == "USAGE" ] && echo "$NORMAL" || echo "$BOLD")

    install_flag_desc="[{-${INSTALL_FLAG[0]}|--${INSTALL_FLAG[1]}}"
    install_flag_desc_indent=$((${#install_flag_desc} + 1))
    fmt_println "$BOLD" "$BLUE" "$3:"
    # install
    fmt_println "$is_bold_flags" "$1 $install_flag_desc"
    fmt_println "$is_short" "Install this script" | indent "$2"
    fmt_println "$is_short"
    # hotspot ssid
    fmt_println "$is_bold_flags" "<{-${HOTSPOT_SSID_FLAG[0]}|--${HOTSPOT_SSID_FLAG[1]}} <${HOTSPOT_SSID_FLAG[3]}>>" | indent $(($2 + install_flag_desc_indent))
    fmt_println "$is_short" "The personal hotspot ssid to try to connect to" | indent $(($2 + install_flag_desc_indent))
    fmt_println "$is_short"
    # trigger ssid
    fmt_println "$is_bold_flags" "[{-${TRIGGER_SSID_FLAG[0]}|--${TRIGGER_SSID_FLAG[1]}} <${TRIGGER_SSID_FLAG[3]}>]" | indent $(($2 + install_flag_desc_indent))
    fmt_println "$is_short" "Specify the trigger ssid. i.e. When this network is around, try to connect to your personal hotspot." | indent $(($2 + install_flag_desc_indent))
    fmt_println "$is_short" "default: connect to your hotspot whenever network changes" | indent $(($2 + install_flag_desc_indent))
    fmt_println "$is_short"
    # retry duration
    fmt_println "$is_bold_flags" "[{-${RETRY_DURATION_FLAG[0]}|--${RETRY_DURATION_FLAG[1]}} <${RETRY_DURATION_FLAG[3]}>]]" | indent $(($2 + install_flag_desc_indent))
    fmt_println "$is_short" "Maximum time duration in seconds to try when trigger conditions are met and not yet connected to hotspot." | indent $(($2 + install_flag_desc_indent))
    fmt_println "$is_short" "default: 600s" | indent $(($2 + install_flag_desc_indent))
    fmt_println "$is_short"
    # uninstall
    fmt_println "$is_bold_flags" "[{-${UNINSTALL_FLAG[0]}|--${UNINSTALL_FLAG[1]}}]" | indent "$2"
    fmt_println "$is_short" "Uninstall this script" | indent "$2"
    fmt_println "$is_short"
    # help
    fmt_println "$is_bold_flags" "[{-${HELP_FLAG[0]}|--${HELP_FLAG[1]}}]" | indent "$2"
    fmt_println "$is_short" "Show help" | indent "$2"
    fmt_println "$is_short"
    # version
    fmt_println "$is_bold_flags" "[{-${VERSION_FLAG[0]}|--${VERSION_FLAG[1]}}]" | indent "$2"
    fmt_println "$is_short" "The version of this script" | indent "$2"
    fmt_println "$is_short"

    # examples
    fmt_println "$is_short" "$BOLD" "============== EXAMPLES ==========================" | indent "$2"
    fmt_println "$is_short" "auto-hotspot.sh -t TRIGGER_SSID -s iPhone" | indent "$2"
    fmt_println
}

# This is a bit of hacking way in that the default value in this plist
# is reserved. i.e. it can occur only once in the correct field.
# Limitation of shell
replace_str_in_plist() {
    sed -i -e "s/$1/$2/g" ./com.nick.auto-hotspot.plist.new
}

check_privilege() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be granted elevated privilege to install/uninstall, i.e. sudo $1"
        exit 1
    fi
}

install() {
    cp ./com.nick.auto-hotspot.plist ./com.nick.auto-hotspot.plist.new
    replace_str_in_plist "HOTSPOT_SSID" "$1"

    if [ -n "$2" ]; then
        replace_str_in_plist "TRIGGER_SSID" "$2"
    else
        replace_str_in_plist "TRIGGER_SSID" ""
    fi

    if [ -n "$3" ]; then
        replace_str_in_plist "600" "$3"
    fi

    cp ./auto-hotspot.sh /Library/Scripts/
    chmod 755 /Library/Scripts/auto-hotspot.sh
    mv ./com.nick.auto-hotspot.plist.new /Library/LaunchDaemons/com.nick.auto-hotspot.plist
    chmod 600 /Library/LaunchDaemons/com.nick.auto-hotspot.plist
    launchctl bootstrap system /Library/LaunchDaemons/com.nick.auto-hotspot.plist
}

uninstall() {
    launchctl bootout system /Library/LaunchDaemons/com.nick.auto-hotspot.plist
    rm /Library/Scripts/auto-hotspot.sh
    rm /Library/LaunchDaemons/com.nick.auto-hotspot.plist
}

# TODO: next version auto grant security keychain access
# TODO: fix getopts unreachable flags when flags like --eee
# TODO: add alerts for uninstall
# TODO: add check for existence for installation
main() {
    trigger_ssid=""
    hotspot_ssid=""
    retry_duration=""
    to_install=false
    has_args=false
    program_indent=$((${#0} + 1))
    optstr=":-:${HELP_FLAG[2]}${VERSION_FLAG[2]}${HOTSPOT_SSID_FLAG[2]}${TRIGGER_SSID_FLAG[2]}${RETRY_DURATION_FLAG[2]}${INSTALL_FLAG[2]}${UNINSTALL_FLAG[2]}"
    while getopts "$optstr" opt; do
        has_args=true
        # support long options: https://stackoverflow.com/a/28466267/519360
        if [ "$opt" = "-" ]; then     # long opt, reformulate OPT and OPTARG
            opt="${OPTARG%%=*}"       # extract long opt name
            OPTARG="${OPTARG#"$opt"}" # extract long opt arg (may be empty)
            OPTARG="${OPTARG#=}"      # if long opt, remove assigning `=`
        fi
        # display Help
        if is_in "$opt" "${HELP_FLAG[@]}"; then
            help "$0" "$program_indent" "USAGE"
            help "$0" "$program_indent" "OPTION"
            exit
        # version
        elif is_in "$opt" "${VERSION_FLAG[@]}"; then
            echo "version"
            exit
        # trigger ssid
        elif is_in "$opt" "${TRIGGER_SSID_FLAG[@]}"; then
            trigger_ssid="$OPTARG"
        # hotspot ssid
        elif is_in "$opt" "${HOTSPOT_SSID_FLAG[@]}"; then
            hotspot_ssid="$OPTARG"
        # retry duration
        elif is_in "$opt" "${RETRY_DURATION_FLAG[@]}"; then
            retry_duration="$OPTARG"
        # install
        elif is_in "$opt" "${INSTALL_FLAG[@]}"; then
            check_privilege "$0"
            to_install=true
        # uninstall
        elif is_in "$opt" "${UNINSTALL_FLAG[@]}"; then
            check_privilege "$0"
            uninstall
            exit
        elif [ -n "$OPTARG" ]; then
            echo "Error, Invalid argument $OPTARG"
            exit 1
        else
            echo "This should be unreachable. Debug required." >&2
        fi
    done
    if ! $has_args; then
        help "$0" "$program_indent" "USAGE"
        exit
    fi
    if $to_install; then
        if [ -n "$hotspot_ssid" ]; then
            install "$hotspot_ssid" "$trigger_ssid" "$retry_duration"
        else
            fmt_println "$RED" "To install, hotspot ssid must be provided"
            fmt_println
            help "$0" "$program_indent" "USAGE"
            exit 1
        fi
    fi
}

main "$@"
