#!/bin/bash

notify (){
	if [ -e /usr/bin/notify-send ]; then
		/usr/bin/notify-send "Network message" "$1"
	fi
}
export notify

notify2 (){
	if [ -e /usr/bin/notify-send ]; then
		/usr/bin/notify-send "$1" "$3" -t 5000 -i "$2"
	fi
}
export notify2

checkIP (){
	DATA=`curl --socks5 localhost:9050 --socks5-hostname localhost:9050 -s https://check.torproject.org/`
        IP=$(curl ifconfig.me)
        countryToFind=`whois $IP |grep country -i -m 1 |cut -d ':' -f 2 | xargs`                                                          
        flagToFind=`echo $countryToFind|sed -e 's/\(.*\)/\L\1/'`   
        flagToShow=`cd /PATH_TO_FLAGS_DIR/;ls|grep $flagToFind`
        MYIP=`whois $IP|grep -E -i "country|city|address|organization|descr"|sort --unique | tail -n 10`
        
        if [ "$DATA" != "" ] && [ "$countryToFind" == "" ]; then 
                notify "You are connected to Tor network\n$MYIP\npublic IP:\t$IP"
        elif [ "$DATA" != "" ] && [ "$countryToFind" != "" ]; then 
                countryFlag=/PATH_TO_FLAGS_DIR/$flagToShow 
                notify2 $countryToFind $countryFlag "You are connected to Tor network\n\n$MYIP\npublic IP:\t$IP"
        elif [ "$IP" == "" ]; then
		notify "Can't connect to internet\nPlease check your settings"
	elif [ "$DATA" == "" ]; then
                countryFlag=/PATH_TO_FLAGS_DIR/$flagToShow 
                notify2 $countryToFind $countryFlag "You are NOT connected to Tor network\n\n$MYIP\npublic IP:\t$IP" 
	fi
}

checkIP
