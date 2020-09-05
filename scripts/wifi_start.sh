#!/bin/sh

WIFI_CONF_FILE="/lumi/conf/wifi.conf"
WPA_SUPPLICANT_CONFIG_FILE="/etc/wpa_supplicant.conf"

wifimode=""

wifi_ap_mode()
{
	model=`cat /lumi/conf/device.conf | grep -v ^# | grep "model" | cut -d '=' -f 2 | tr '.' '-'`
	mac=`cat /sys/class/net/wlan0/address | tr -d ':' | tr 'a-z' 'A-Z' | cut -c 9-12`
	ssid=${model}"_miap"${mac}
	echo $ssid
	sed -i "/^ssid=/c\ssid=${ssid}" `grep "ssid=*" -rl /wpa/hostapd.conf`
	sync

	ifconfig wlan0 down
	killall udhcpc wpa_supplicant hostapd dhcpd
	ifconfig wlan0 up

	sleep 0.5

	ifconfig wlan0 192.168.1.1 netmask 255.255.255.0
	
	ifconfig wlan0 up

	mkdir -p /var/run/hostapd
	/wpa/hostapd /wpa/hostapd.conf -ddB

	mkdir -p /var/lib/dhcp
	touch /var/lib/dhcp/dhcpd.leases
	udhcpd /wpa/udhcpd.conf &
	sleep 0.5

	/home/root/control_light.sh &
}

wifi_sta_mode()
{
    get_ssid_passwd
    echo $user_ssid $passwd

	if [ x"$passwd" = x ]; then	
		cat <<EOF > $WPA_SUPPLICANT_CONFIG_FILE
ctrl_interface=/var/run/wpa_supplicant
update_config=1
network={
	ssid="$user_ssid"
	scan_ssid=1
	key_mgmt=NONE
}
EOF
    else
		cat <<EOF > $WPA_SUPPLICANT_CONFIG_FILE
ctrl_interface=/var/run/wpa_supplicant
update_config=1

network={
	ssid="$user_ssid"
	scan_ssid=1
	psk="$passwd"
	key_mgmt=WPA-PSK
	proto=WPA WPA2
}
EOF
    fi  
    
    ifconfig wlan0 down
    killall udhcpc wpa_supplicant hostapd dhcpd

    ifconfig wlan0 up
    iwconfig wlan0 mode Managed
    mkdir -p /var/run/wpa_supplicant

    wpa_supplicant  -D  nl80211  -i  wlan0  -c /etc/wpa_supplicant.conf   -B
    udhcpc -i wlan0 -s /wpa/simple.script

    # check if we've got ip
	echo "get ip addr :"
    ifconfig wlan0 | grep "inet addr" | cut -d ':' -f 2 |cut -d ' ' -f 1
}

get_ssid_passwd()
{
    STRING=`cat $WIFI_CONF_FILE | grep -av ^#`
    key_mgmt=${STRING##*key_mgmt=}
    if [ "$key_mgmt"x = "NONE"x ]; then
		passwd=""

		user_ssid=${STRING##*ssid=\"}
		user_ssid=${user_ssid%%\"*}
	else
		passwd=${STRING##*psk=\"}
		passwd=${passwd%%\"*}

		user_ssid=${STRING##*ssid=\"}
		user_ssid=${user_ssid%%\"*}
    fi
}

start()
{
    if [ -e $WIFI_CONF_FILE ]; then
		wifi_sta_mode &
		sleep 15
		
		# fallback to AP mode if something went wrong
		up=`cat /sys/class/net/wlan0/carrier`
		if [ "$up" != "1" ]; then
			wifi_ap_mode
		fi
    else
		wifi_ap_mode
    fi
}

start
