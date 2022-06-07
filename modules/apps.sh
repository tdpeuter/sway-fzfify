#!/usr/bin/env bash
# List available applications.
# Just run the script

# Commaseparated list of directories
supported_dirs=~/.local/share/applications,/usr/share/applications

list=$( \
    find {~/.local/share/applications,/usr/share/applications} \
    -iname "*.desktop"
)

for file in ${list} ; do
    Display=$( grep -m 1 "^NoDisplay=" "${file}" )
    if [[ ! "${Display#*=}" =~ ^true$ ]] ; then 
        Name=$( grep -m1 "^Name=" "${file}" )
        Exec=$( grep -m1 "^Exec=" "${file}" )
        Terminal=$( grep -m1 "^Terminal=" "${file}" \
            | grep -o 'true' \
            | sed "s/true/alacritty -e /" )
        echo "${Name#*=};${Terminal}${Exec#*=}"
    fi
done
