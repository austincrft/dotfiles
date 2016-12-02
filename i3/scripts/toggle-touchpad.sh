#!/bin/bash

PublishNotification ()
{
    notify-send --expire-time 2000 --icon=gtk-info INFO "$1"
}

if synclient -l | grep "TouchpadOff .*=.*0" ; then
    synclient TouchpadOff=1 ;
    PublishNotification "Touchpad Turned OFF"
else
    synclient TouchpadOff=0 ;
    PublishNotification "Touchpad Turned ON"
fi
