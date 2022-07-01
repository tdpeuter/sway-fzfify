#!/usr/bin/env bash
# List available applications.
# Just run the script

# Strip commands from codes that we don't need.
stripper() {

    str=$1
    str=${str//\%f/}
    str=${str//\%F/}
    str=${str//\%u/}
    str=${str//\%U/}
    str=${str//\%d/}
    str=${str//\%D/}
    str=${str//\%n/}
    str=${str//\%N/}
    str=${str//\%i/}
    str=${str//\%c/}
    str=${str//\%k/}
    str=${str//\%v/}
    str=${str//\%m/}
    echo $str

}
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
        Exec=$( stripper $( grep -m1 "^Exec=" "${file}" ))
        Terminal=$( grep -m1 "^Terminal=" "${file}" \
            | grep -o 'true' \
            | sed "s/true/alacritty -e /" )
        echo "${Name#*=};${Terminal}${Exec#*=}"
    fi
done
