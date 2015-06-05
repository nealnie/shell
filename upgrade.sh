#!/bin/bash
ssh -o StrictHostKeyChecking=no root@$j "wget $httpser$rom -P /tmp && mtd -q write /tmp/$rom firmware && reboot" 
if [ $? -eq 0 ] ;then
	echo upgrade $mac ok && echo $(date) $mac ok >>$log
else
	echo upgrade $mac failed && echo $(date) $mac failed >>$log
fi
