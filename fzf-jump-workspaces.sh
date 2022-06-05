#!/usr/bin/env bash
# Write available workspaces to a file.
# Syntaxis: workspaces <filename>

destination="${1-/tmp/fzf-jump.txt}"
touch "${destination}"

workspaces=$( swaymsg -t get_workspaces -r \
    | jq -r -c '.[] .name'
)

while read line ; do
    echo "_WO ${line};swaymsg workspace ${line}" >> "${destination}"
done <<< "${workspaces}"
