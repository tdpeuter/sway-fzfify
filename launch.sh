#!/usr/bin/env bash
# Launch some modules
# Syntaxis: launch [-f <cache file>] {path to modules}

# TODO Error handling
# TODO Argument checking

panic () {
    >&2 echo "Launch: Syntaxis: launch [-f <cache file>] {path to modules}"
    exit 1
}

list="$HOME/.cache/fzf-jump/cache"
hist="$HOME/.cache/fzf-jump/history"

# Get options
while getopts ":f:" option ; do
    case "${option}" in 
        f)
            list="${OPTARG}"
            
            if [[ ! -f "${list}" ]] ; then
                >&2 echo "Launch: \"${list}\" does not exist\nMaking file..."
                touch "${list}"
            fi

            if [[ ! -r "${list}" ]] ; then 
                >&2 echo "Launch: \"${list}\" is not readable"
                exit 2
            fi

            if [[ ! -w "${list}" ]] ; then 
                >&2 echo "Launch: \"${list}\" is not writable"
            fi
            ;;
        *) 
            panic
            ;;
    esac
done

# Update the cache file in the background
$(dirname ${0})/update.sh $@ &

# Pick something with fzf.
selection=$( cat "${list}" \
    | cut -f1 -d';' \
    | fzf --history="${hist}" \
          --cycle \
          --bind "change:reload(cat ${list} | cut -f1 -d';')" \
          --border=sharp \
          --layout="reverse"
)
selection=$( echo -n "${selection}" )

# Execute the command or start the application in another process.
ex=$(grep "^${selection};.*$" "${list}" | cut --complement -f1 -d';')
setsid --fork $SHELL -c "${ex}" &> /dev/null
