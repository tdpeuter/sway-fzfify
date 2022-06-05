#!/usr/bin/env bash
# Launch an application finder...
# Just run this script.

# =========
# Functions
# =========

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

# =========
# Variables
# =========

list=/tmp/fzf-jump.txt
touch "${list}"
hist=/tmp/fzf-jump-hist.txt

# ====
# Init
# ====

setsid --fork $SHELL -c "$(dirname $0)/fzf-jump-apps.sh ${list}"
setsid --fork $SHELL -c "$(dirname $0)/fzf-jump-windows.sh ${list}"
setsid --fork $SHELL -c "$(dirname $0)/fzf-jump-workspaces.sh ${list}"

# ===============
# FZF and execute
# ===============

# Pick something with fzf.
selection=$( cat ${list} \
    | cut -f1 -d';' \
    | fzf --history=${hist} \
          --cycle \
          --bind "change:reload(cat ${list} | cut -f1 -d';')"
)
selection=$( echo -n "${selection}" )

# Special actions if nothing selected, read input.
if [[ -z "${selection}" ]] ; then 
    ((elapsedSeconds = $(date +%s) - $(date +%s -r "${hist}") ))
    if [[ ${elapsedSeconds} -gt 2 ]] ; then 
        rm ${list}
        exit
    fi

    action=$( tail -n 1 "${hist}" )

    prefix=''
    suffix='! '
    
    # Move to new workspace.
    if [[ "${action}" =~ ^${prefix}GT${suffix} ]] ; then
        name=${action#"${prefix}GT${suffix}"}
        swaymsg focus tiling
        swaymsg move window to workspace "${name}"
        swaymsg workspace "${name}"
    
    # Rename workspace
    elif [[ "${action}" =~ ^${prefix}R${suffix} ]] ; then 
        name=${action#"${prefix}R${suffix}"}
        swaymsg rename workspace to "${name}"
        ~/.scripts/notify.sh -t 1000 "${name}" "Switched workspaces"
    
    # Execute the given command (this is assumed).
    else
        # TODO Fix this.
        setsid $SHELL -c "${action}"
    fi
fi

ex=$(stripper "$(grep "^${selection};.*$" "${list}" | cut --complement -f1 -d';')")

# Execute the command.
setsid --fork $SHELL -c "${ex}" &> /dev/null

rm ${list}
