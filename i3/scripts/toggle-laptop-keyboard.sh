#!/bin/sh

GetMasterID ()
{
    local id=$(xinput | grep -Po "Virtual core keyboard\s+id=\K\d+")
    echo $id
}

GetUsbKeyboard ()
{
    local master_id=$1
    local regex="USB Keyboard\s+id=\K\d+\s\[slave\s+keyboard\s+\($master_id\)\]"
    local id=$(xinput | grep -oP "$regex" | awk '{print $1}')
    echo $id
}

GetAppleKeyboardID ()
{
    local regex="Apple Internal Keyboard / Trackpad\s+id=\K\d+"
    local text="$(xinput | grep -Po "$regex")"
    echo $text
}

AppleKeyboardIsAttached ()
{
    local regex="Apple Internal Keyboard / Trackpad\s+id=\d+\s+\K\[.*\]"
    local capture="$(xinput | grep -Po "$regex")"
    local is_floating="$(echo $capture | grep "floating")"

    if [ -z "$is_floating" ]; then
        echo true
    else
        echo false
    fi
}

PublishNotification ()
{
    notify-send --expire-time 2000 --icon=gtk-info INFO "$1"
}

MASTER_ID=$(GetMasterID)
if [ -z "$MASTER_ID" ]; then
    ERROR_MSG="Could not find Master keyboard ID"
    echo "$ERROR_MSG"
    PublishNotification "$ERROR_MSG"
    exit 1
fi
echo "Master Keyboard ID: $MASTER_ID"

USB_KEYBOARD=$(GetUsbKeyboard $MASTER_ID)
if [ -z "$USB_KEYBOARD" ]; then
    ERROR_MSG="USB Keyboard is not plugged in"
    echo "$ERROR_MSG"
    PublishNotification "$ERROR_MSG"
    exit 1
fi
echo "USB Keyboard ID: $USB_KEYBOARD"

APPLE_ID=$(GetAppleKeyboardID)
if [ -z "$APPLE_ID" ]; then
    ERROR_MSG="Could not find Apple keyboard ID"
    echo "$ERROR_MSG"
    PublishNotification "$ERROR_MSG"
    exit 1
fi
echo "Apple Keyboard ID: $APPLE_ID"

IS_ATTACHED=$(AppleKeyboardIsAttached)
echo "Attached: $IS_ATTACHED"

if [ "$IS_ATTACHED" = true ]; then
    COMMAND="xinput float $APPLE_ID"
    PublishNotification "Laptop Keyboard Turned OFF"
else
    COMMAND="xinput reattach $APPLE_ID $MASTER_ID"
    PublishNotification "Laptop Keyboard Turned ON"
fi
echo "Command: $COMMAND"

$($COMMAND)
