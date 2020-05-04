#!/bin/bash

function notify {
	if [ -e /usr/bin/notify-send ]; then
		/usr/bin/notify-send "Your public IP:" "$1"
	fi
}

function ip {
        flagToFind=`whois $(curl ifconfig.me)|grep country|sed 's/country:'//|sort --unique|sed -e 's/\(.*\)/\L\1/'`
        flagToShow=`cd /usr/share/iso-flags-svg/country-4x3/;ls|grep $flagToFind`
	MYIP=`whois $(curl ifconfig.me)|grep -E -i "cidr|country|city|address|organization|descr"|sort`
        notify "$MYIP\npuplic IP:\t$(curl ifconfig.me)"
        sleep 1.0
        notify-send "is your exit node " -i /usr/share/iso-flags-svg/country-4x3/$flagToShow
}
