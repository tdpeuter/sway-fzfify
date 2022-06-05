#!/usr/bin/env bash
# Write available applications to a file.
# Syntaxis: apps <filename>

destination="${1:-/tmp/fzf-jump.txt}"
touch "${destination}"

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
        echo "${Name#*=};${Terminal}${Exec#*=}" >> "${destination}"
    fi

done
