term="$( which kitty )"
maximum_length=30
# Choose your favorite menu
menu="$( which rofi  ) -dmenu -i"
menu="$( which dmenu ) -i"

# All entries and their respective commands are stored in an associative array.
declare -A lut

function list_windows() {
    windows="$(hyprctl clients -j | jq -r '
        .[]? |
        "\(.address);\(.class);\(.title)"
    ')"
    
    while IFS=';' read id app name; do
        str="${app:+(${app}) }${name:0:${maximum_length}}"

        lut["${str}"]="hyprctl dispatch focuswindow address:${id}"
    done <<< "${windows}"
}

function focus_window() {
    hyprctl dispatch focuswindow "address:${1%%;*}"
}

function list_workspaces() {
    workspaces="$( hyprctl workspaces -j |
        jq -r -c '.[] .name'
    )"

    while read -r line; do
        lut["(Workspace) ${line}"]="hyprctl dispatch workspace ${line}"
    done <<< "${workspaces}"
}

function focus_workspace() {
    hyprctl dispatch workspace "${1}"
}

function rename_workspace() {
    hyprctl dispatch renameworkspace "${1}" "${2}"
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
hyprctl dispatch exec -- "${result:-${pick}}"
