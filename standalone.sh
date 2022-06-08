#!/usr/bin/env bash
# This is a standalone launcher
# Syntaxis: standalone {modules seperated by space}

while [[ $# -gt 0 ]] ; do
    if [[ ! -f "$1" ]] ; then 
        "$1 does not exist or is unreadable"    
        exit 1
    fi
    list+="$($1)"
    shift

    # If there is a next script to run, add newline.
    if [[ $# -gt 0 ]] ; then
        list+="\n"
    fi
done

selection=$( printf "${list}" \
    | cut -f1 -d';' \
    | fzf --cycle \
          --border=sharp \
          --layout="reverse" \
          --bind "tab:down" \
          --bind "shift-tab:up"
)

selection=$( echo -n "${selection}" )

setsid --fork $SHELL -c "$(grep "^${selection};.*$" <<< "${list}" | cut --complement -f1 -d';')"

