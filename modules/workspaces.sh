#!/usr/bin/env bash
# List available workspaces.
# Just run the script

workspaces=$( swaymsg -t get_workspaces -r \
    | jq -r -c '.[] .name'
)

while read line ; do
    echo "_WO ${line};swaymsg workspace ${line}"
done <<< "${workspaces}"
