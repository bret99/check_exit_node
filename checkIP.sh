#!/bin/bash

function notify {
	if [ -e /usr/bin/notify-send ]; then
		/usr/bin/notify-send "Network message" "$1"
	fi
}
export notify

function notify2 {
	if [ -e /usr/bin/notify-send ]; then
		/usr/bin/notify-send "$1" "$3" -t 5000 -i "$2"
	fi
}
export notify2

function checkIP {
	DATA=`curl --socks5 localhost:9050 --socks5-hostname localhost:9050 -s https://check.torproject.org/`
        IP=$(curl ifconfig.me)
        countryToFind=`whois $IP|grep ountry|sed 's/country://; s/Country://'|head -n 1`                                                          
        flagToFind=`echo $countryToFind|sed -e 's/\(.*\)/\L\1/'`   
        flagToShow=`cd /usr/share/icons/mate/scalable/animations/;ls|grep $flagToFind`
        MYIP=`whois $IP|grep -E -i "country|city|address|organization|descr"|sort --unique | tail -n 10`
        
        if [ "$DATA" != "" ] && [ "$countryToFind" == "" ]; then 
                notify "You are connected to Tor network\n$MYIP\npublic IP:\t$IP"
        elif [ "$DATA" != "" ] && [ "$countryToFind" != "" ]; then 
                countryFlag=/usr/share/icons/mate/scalable/animations/$flagToShow 
                notify2 $countryToFind $countryFlag "You are connected to Tor network\n\n$MYIP\npublic IP:\t$IP"
	else
		if [ "$IP" == "" ]; then
			notify "Can't connect to internet\nPlease check your settings"
		else
                    countryFlag=/usr/share/icons/mate/scalable/animations/$flagToShow 
                    notify2 $countryToFind $countryFlag "You are NOT connected to Tor network\n\n$MYIP\npublic IP:\t$IP" 
		fi
	fi
}

