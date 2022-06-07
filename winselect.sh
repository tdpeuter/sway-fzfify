#!/usr/bin/env bash
# Launch a window selector (this is a standalone launcher)
# Just run this script.

list=$("$(dirname $0)/modules/windows.sh")

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

