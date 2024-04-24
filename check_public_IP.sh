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
        IP=$(curl ip.me)
        countryToFind=`whois $IP | grep country -i -m 1 |cut -d ':' -f 2 | xargs`                                                          
        flagToFind=`echo $countryToFind|sed -e 's/\(.*\)/\L\1/'`   
        flagToShow=`cd /usr/share/iso-country-flags/64/;ls|grep -i $flagToFind`
        MYIP=`whois $IP|grep -E -i "country|city|address|organization|descr"|sort --unique | tail -n 10`
        
        if [ "$DATA" != "" ] && [ "$countryToFind" == "" ]; then 
#                notify "You are connected to Tor network\npublic IP:\t$IP\n$MYIP"
                zenity --info --title "You are connected to Tor network" --text "public IP:\t$IP\n$MYIP"
        elif [ "$DATA" != "" ] && [ "$countryToFind" != "" ]; then 
                countryFlag=/usr/share/iso-country-flags/64/$flagToShow 
                zenity --window-icon $countryFlag --info --title "You are connected to Tor network" --text "public IP:\t$IP\n$MYIP"
#                notify2 $countryToFind $countryFlag "You are connected to Tor network\npublic IP:\t$IP\n$MYIP"
        elif [ "$IP" == "" ]; then
		notify "Can't connect to internet\nPlease check your settings"
	elif [ "$DATA" == "" ]; then
                countryFlag=/usr/share/iso-country-flags/64/$flagToShow 
#                notify2 $countryToFind $countryFlag "You are not connected to Tor network\npublic IP:\t$IP\n$MYIP"
                zenity --window-icon $countryFlag --info --title "You are not connected to Tor network" --text "public IP:\t$IP\n$MYIP"
	fi
}

checkIP
