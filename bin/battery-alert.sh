#!/bin/bash

# Source : github.com/asapdotid/battery-alert-linux/blob/main/battery-alert


battery_alert_sh_func1() {


sleep 10
while true; do
    export DISPLAY=:0.0

    while read line; do
        value=$(echo $line | sed 's/%//g' | cut -d " " -f 2)
        key=$(echo $line | sed 's/%//g' | cut -d ":" -f 1)

        if [ $key = 'state' ]; then
            bat_state=$value
        else
            bat_percent=$value
        fi
    done < <(upower -i $(upower -e | grep BAT) | grep -E "percentage|state")

    if [ $bat_state == 'discharging' ]; then
        if [ $bat_percent -lt 30 ]; then
            dunstify --urgency=CRITICAL "Battery Low" "Level: ${bat_percent}%"
            paplay /usr/share/sounds/freedesktop/stereo/suspend-error.oga
        fi
    else
        if [ $bat_percent -ge 100 ]; then
            :
            # printf "Fully Charged \n"
            # dunstify --urgency=NORMAL "Battery Full" "Level: ${bat_percent}%"
        fi
    fi

    sleep 10
done




}

battery_alert_sh_original() {


sleep 10
while true; do
    export DISPLAY=:0.0

    while read line; do
        value=$(echo $line | sed 's/%//g' | cut -d " " -f 2)
        key=$(echo $line | sed 's/%//g' | cut -d ":" -f 1)

        if [ $key = 'state' ]; then
            bat_state=$value
        else
            bat_percent=$value
        fi
    done < <(upower -i $(upower -e | grep BAT) | grep -E "percentage|state")

    if [ $bat_state == 'discharging' ]; then
        if [ $bat_percent -lt 30 ]; then
            dunstify --urgency=CRITICAL "Battery Low" "Level: ${bat_percent}%"
            paplay /usr/share/sounds/freedesktop/stereo/suspend-error.oga
        fi
    else
        if [ $bat_percent -ge 100 ]; then
            dunstify --urgency=NORMAL "Battery Full" "Level: ${bat_percent}%"
        fi
    fi

    sleep 10
done



}



battery_alert_sh_func1
