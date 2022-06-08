#!/usr/bin/env bash
# Connect to devices etc
# Just run this script
# Depends on bluetoothctl

# Check powered on
if [[ $( bluetoothctl show | grep Powered | sed "s/^.*Powered: //" ) == 'no' ]] ; then 
    echo "Turn bluetooth on;bluetoothctl power on"
    exit
else
    echo "Turn bluetooth off;bluetoothctl power off"
fi

# If currently connected; offer to disconnect.
info=$( bluetoothctl info )
if [[ $( wc -l <<< "${info}" ) != 1 ]] ; then 
    bluetoothctl info \
        | grep Alias \
        | sed "s/^.*Alias: \(.*\)$/Disconnect from \1;bluetoothctl disconnect/"
fi

# List paired devices
sed "s/^[^ ]* \([^ ]*\) \(.*\)$/Connect to \2;bluetoothctl connect \1/g" <<< $(bluetoothctl paired-devices)
