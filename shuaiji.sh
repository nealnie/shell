#!/bin/bash
net=192.168.112.
romdir=/root/bin
rom=openwrt-ar71xx-generic-APS256-squashfs-sysupgrade.bin
log=/root/upgrade.log
httpser=http://$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}' | grep $net ):9000/
##start httpserver to share roms
kill -9 $(pidof python)
cd $romdir && python -m SimpleHTTPServer 9000 &
sleep 1s
##start searching and upgrade
[ -f /tmp/device.txt ] && rm -f /tmp/device.txt
echo searching device ...
##searching scope is 192.168.111.100-150
for i in $(seq 100 150); do
	ping -c1 $net$i >/dev/nul 2>&1 && echo found $net$i
	if [ $? -eq 0 ] ;then
		j=`echo $net$i`
		mac=`cat /proc/net/arp | grep -w "$j" | awk '{print $4}'`
		echo upgrade device ip: $net$i mac: $mac
		if [ $(echo $mac | awk -F ":" '{print $1$2$3}') = "009bcd" ] ;then
			#read -p "press any key to continue upgrade $mac"
			ssh -o StrictHostKeyChecking=no root@$j "wget $httpser$rom -P /tmp && mtd -q write /tmp/$rom firmware && reboot"
			if [ $? -eq 0 ] ;then
				echo upgrade $mac ok && echo $(date) $mac ok >>$log
			else
				echo upgrade $mac failed && echo $(date) $mac failed >>$log
			fi
		else
			echo $net$i is not xiaoluwifi
		fi
	else
		echo $net$i no respond
	fi
done
kill -9 $(ps aux | grep "python -m SimpleHTTPServer 9000" | grep -v "grep" | awk '{print $2}')
