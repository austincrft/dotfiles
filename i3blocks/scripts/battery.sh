#!/bin/sh

BATTERY=BAT0

if test -e "/sys/class/power_supply/$BATTERY"; then
    # Charging
    status=$(cat /sys/class/power_supply/$BATTERY/status)
    if [ "$status" == "Charging" ]; then
        charging=" "
    fi

    # Capacity
    capacity=$(cat /sys/class/power_supply/$BATTERY/capacity)

    # 4/4 Full
    if test  $capacity -le 100 -a $capacity -ge 76; then
        symbol=""
    fi

    # 3/4 Full
    if test  $capacity -le 75 -a $capacity -ge 51; then
        symbol=""
    fi

    # 2/4 Full
    if test  $capacity -le 50 -a $capacity -ge 26; then
        symbol=""
    fi

    # 1/4 Full
    if test  $capacity -le 25 -a $capacity -ge 0; then
        symbol=""
    fi

    # Full text
    echo "$symbol $capacity%$charging"
fi
