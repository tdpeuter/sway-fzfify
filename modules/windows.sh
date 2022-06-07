#!/usr/bin/env bash
# List available windows.
# Just run the script

# Extract id, application name and title from swaytree.
windows=$( swaymsg -t get_tree \
    | jq -r "recurse(.nodes[]?) \
        | recurse(.floating_nodes[]?) \
        | select(.type==\"con\"), select(.type==\"floating_con\") \
        | select((.app_id != null or .name != null) and .name != \"FZF-Jump\") \
        | {id, app_id, name} \
        | .id, .app_id, .name" \
    | tr "\n" ";" \
    | sed -e "s/\(\([^;]*;\)\{2\}[^;]*\);/\1\n/g" \
    | sed "s/;null//g"
)
    
while read line ; do 
    id=$( cut -f1 -d';' <<< "${line}" )
    app=" $( cut -f2 -d';' <<< "${line}" )"
    name=" ($( cut -f3 -d';' <<< "${line}" ))"

    # Filter empty fields \uf2d0
    str="_WI${name#' ()'}${app#' $'}"

    echo "${str};swaymsg \"[con_id=${id}]\" focus"
done <<< "${windows}"
