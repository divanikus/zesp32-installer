#!/bin/sh

# zigbee update
if [ -f "/opt/app/util/need_update_coordinator.tag" ];then
    echo "start update zigbee coordinator"
    sleep 2
    /home/root/control_blue.light.sh &
    pushd /opt/app/util/
        sleep 1
        echo "echo 0 -->> dev/watchdog"
        echo 0 > /dev/watchdog
        echo -n V > /dev/watchdog
        /opt/app/util/flash /opt/app/util/Zigbee.bin > /tmp/update_coordinator.log 
    popd
    killall  control_blue.light.sh 
    if [ "`cat /tmp/update_coordinator.log | grep "Success"`" != "" ];then
        echo "update zigbee coordinator ok"
        rm /opt/app/util/need_update_coordinator.tag

        echo 0 > /sys/class/backlight/lumi_r/brightness
        echo 10 > /sys/class/backlight/lumi_g/brightness
        echo 0 > /sys/class/backlight/lumi_b/brightness
    else
        echo "update zigbee coordinator failed:"
        cat /tmp/update_coordinator.log
        echo 0 > /sys/class/backlight/lumi_r/brightness
        echo 0 > /sys/class/backlight/lumi_g/brightness
        echo 10 > /sys/class/backlight/lumi_b/brightness
    fi
    sleep 2

    echo 0 > /sys/class/backlight/lumi_r/brightness
    echo 0 > /sys/class/backlight/lumi_g/brightness
    echo 0 > /sys/class/backlight/lumi_b/brightness
fi
