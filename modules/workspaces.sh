#!/usr/bin/env bash
# List available workspaces.
# Just run the script

workspaces=$( swaymsg -t get_workspaces -r \
    | jq -r -c '.[] .name'
)

sed "s/^.*$/_WO &;swaymsg workspace &/g" <<< "${workspaces}"
