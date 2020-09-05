#!/bin/bash

UTILS_HOST=codeload.github.com
UTILS_URL=/divanikus/zesp32-installer/zip/master
UTILS_DIR=/opt/utils
PKG_URL=http://82.146.46.112/fw/mihub.tar.gz
PKG=/tmp/m.tgz

w_get() {
    echo -e "GET $2 HTTP/1.0\nHost: $1\n" | openssl s_client -quiet -connect $1:443 2>/dev/null | sed '1,/^\r$/d' > $3
}

echo Updating time...
ntpdate pool.ntp.org

echo
echo Downloading ZESP32...
if ! wget -O $PKG $PKG_URL; then
    echo Download failed.
    exit -1
fi

echo
echo Unpacking...
if ! tar -xzvf $PKG -C /; then
    echo Unpacking failed, please check available space and try again.
    exit -1
fi
rm $PKG
ln -fs /opt/node/bin/npm /usr/bin/npm
ln -fs /opt/node/bin/node /usr/bin/node

echo
echo Detecting Wifi module...
MODULE=unknown
if lsmod | grep 8723bs >/dev/null; then
    MODULE=8723bs
elif lsmod | grep 8189es >/dev/null; then
    MODULE=8189es
else
    echo Unknown Wifi module
    exit -1
fi
echo Found $MODULE

echo
echo Downloading utils...
WORKDIR=$(mktemp)
mkdir -p $UTILS_DIR
w_get $UTILS_HOST $UTILS_URL $WORKDIR/master.zip
if ! unzip $WORKDIR/master.zip -d $WORKDIR; then
    echo Download failed. Please try again.
    exit -1
fi

mv $WORKDIR/zesp32-installer-master/scripts/*.sh $UTILS_DIR
chmod +x $UTILS_DIR/*.sh
# Enabling automatic Zigbee flashing on boot
touch /opt/app/util/need_update_coordinator.tag

echo
echo Installing modified rc.local...
TS=$(date +%s)
cp /etc/rc.local /etc/rc.local.bak-$TS
echo Previous version is in /etc/rc.local.bak-$TS
mv $WORKDIR/zesp32-installer-master/rc.$MODULE.local /etc/rc.local
chmod +x /etc/rc.local

echo
echo Current WiFi settings:
cat /lumi/conf/wifi.conf

echo
echo =================================================================
echo ZESP32 installation completed. Device will restart in 10 seconds.
echo Press Ctrl+C to cancel automatic restart.
echo =================================================================
sleep 10

#reboot
