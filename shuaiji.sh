#!/bin/bash
net=192.168.111.
rom=openwrt-ar71xx-generic-APS256-squashfs-sysupgrade.bin
log=upgrade.log
httpser=http://192.168.111.187/bin/
##start searching and upgrade
[ -f /tmp/device.txt ] && rm -f /tmp/device.txt
echo searching device ...
##searching scope is 192.168.111.100-150
for i in $(seq 1 100); do
	ping -c1 $net$i >/dev/nul 2>&1 && echo found $net$i
	if [ $? -eq 0 ] ;then
		j=`echo $net$i`
		mac=`cat /proc/net/arp | grep -w "$j" | awk '{print $4}'`
		echo upgrade device ip: $net$i mac: $mac
		if [[ $(echo $mac | awk -F ":" '{print $1$2$3}') = "009bcd" ]] ;then
			#read -p "press any key to continue upgrade $mac"
			source upgrade.sh 
		else
			echo $net$i is not xiaoluwifi
		fi
	else
		echo $net$i no respond
	fi
done
