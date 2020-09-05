#!/bin/sh

RED=0
GREEN=0
BLUE=0

case $1 in
    red)
        RED=10
        ;;
    green)
        GREEN=10
        ;;
    blue)
        BLUE=10
        ;;
    white)
        RED=10
        GREEN=10
        BLUE=10
        ;;
    yellow)
        RED=10
        GREEN=10
        ;;
    magenta)
        RED=10
        BLUE=10
        ;;
    cyan)
        GREEN=10
        BLUE=10
        ;;
    *)
        ;;
esac

echo $BLUE > /sys/class/backlight/lumi_r/brightness
echo $GREEN > /sys/class/backlight/lumi_g/brightness
echo $RED > /sys/class/backlight/lumi_b/brightness

sleep 1

echo 0 > /sys/class/backlight/lumi_r/brightness
echo 0 > /sys/class/backlight/lumi_g/brightness
echo 0 > /sys/class/backlight/lumi_b/brightness

exit 0