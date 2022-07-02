#!/usr/bin/env bash
# Update the cache file, run this as a forked script so it updates in the background.
# Syntaxis: update {modules seperated by space}

cache_file="$HOME/.cache/fzf-jump/cache"

# Run modules
while [[ $# -gt 0 ]] ; do
    list+="$(${1})"
    shift

    # If there is a next script to run, add newline.
    if [[ $# -gt 0 ]] ; then 
        list+="\n"
    fi
done

# Replace cache file
echo "${list}" > "${cache_file}"
