term="$( which kitty )"
maximum_length=30
# Choose your favorite menu
menu="$( which rofi  ) -dmenu -i"
menu="$( which dmenu ) -i"

# All entries and their respective commands are stored in an associative array.
declare -A lut

function list_windows() {
    windows="$( swaymsg -t get_tree | jq -r '
        recurse(.nodes[]?, .floating_nodes[]?) |
        select(.type == "con" or type == "floating_con") |
        select(.app_id != null or .name != null) |
        "\(.id);\(.app_id // "")\(.window_properties.instance // "");\(.name // "")"
    ')"
    
    while IFS=';' read id app name; do
        str="${app:+(${app}) }${name:0:${maximum_length}}"

        lut["${str}"]="swaymsg [con_id=${id}] focus"
    done <<< "${windows}"
}

function focus_window() {
    swaymsg "[con_id=${1%%;*}]" focus
}

function list_workspaces() {
    workspaces="$( swaymsg -t get_workspaces -r |
        jq -r -c '.[] .name'
    )"

    while read -r line; do
        lut["(Workspace) ${line}"]="swaymsg workspace ${line}"
    done <<< "${workspaces}"
}

function focus_workspace() {
    swaymsg workspace "${1}"
}

function rename_workspace() {
    swaymsg rename workspace "${1}" to "${2}"
}

function rename_current_workspace() {
    rename_workspace '' "${1}"
}

function bluetooth() {
    if [[ $( bluetoothctl show | grep Powered | sed "s/^.*Powered: //" ) == 'no' ]] ; then 
        lut["(Bluetooth) Power on"]="bluetoothctl power on"
    else
        lut["(Bluetooth) Power off"]="bluetoothctl power off"
        bluetooth_list_devices
        bluetooth_offer_disconnect
    fi
}

function bluetooth_list_devices() {
    # Output of bluetoothctl looks like:
    # Device XX:XX:XX:XX:XX:XX Name
    while IFS=' ' read -r _ id name; do
        lut["(Bluetooth) Connect to ${name}"]="bluetoothctl connect ${id}"
    done <<< "$( bluetoothctl devices )"
}

function bluetooth_offer_disconnect() {
    while IFS=' ' read -r _ id name; do
        unset lut["(Bluetooth) Connect to ${name}"] # Remove the existing entry
        lut["(Bluetooth) Disconnect from ${name}"]="bluetoothctl disconnect ${id}" # Replace with discconect
    done < <( bluetoothctl devices Connected )
}

function load_modules() {
    list_windows
    list_workspaces
}

load_modules
pick="$( printf "%s\n" "${!lut[@]}" | ${menu} )"
result="${lut["${pick}"]}"
# Execute the complementary command or whatever custom command was given.
swaymsg exec -- "${result:-${pick}}"
