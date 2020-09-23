#!/bin/bash

export BLUE='\033[1;94m'
export GREEN='\033[1;92m'
export RED='\033[1;91m'
export RESETCOLOR='\033[1;00m'

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

function kill-apps {
	echo -e -n "$BLUE[$GREEN*$BLUE] Killing dangerous applications\n"
	sudo killall -q chrome dropbox skype icedove thunderbird firefox firefox-esr chromium xchat hexchat transmission steam firejail
	echo -e -n "$BLUE[$GREEN*$BLUE] Dangerous applications killed\n"

	echo -e -n "$BLUE[$GREEN*$BLUE] cleaning some dangerous cache elements\n"
	bleachbit -c adobe_reader.cache chromium.cache chromium.current_session chromium.history elinks.history emesene.cache epiphany.cache firefox.url_history flash.cache flash.cookies google_chrome.cache google_chrome.history  links2.history opera.cache opera.search_history opera.url_history &> /dev/null
	echo -e -n "$BLUE[$GREEN*$BLUE] Cache cleaned\n"
        sleep 1.5
}

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


function checkuid {
	ME=$(whoami | tr [:lower:] [:upper:])
	if [ $(id -u) -ne 0 ]; then
		echo -e "\n$GREEN[$RED!$GREEN] $RED $ME This script should be run as root$RESETCOLOR\n" >&2
		exit 1
	fi
}


function start {
	echo -e "\n$GREEN[$BLUE i$GREEN ]$BLUE Starting anonymous mode:$RESETCOLOR\n"
	/usr/sbin/service anonsurfd start
	echo -e "$GREEN *$BLUE Starting tor service"
	echo -e "$GREEN *$BLUE All traffic is redirected throught Tor\n"
	sleep 1.5
}


function stop {
	echo -e "\n$GREEN[$BLUE i$GREEN ]$BLUE Stopping anonymous mode:$RESETCOLOR\n"
	/usr/sbin/service anonsurfd stop
	echo -e " $GREEN*$BLUE Anonymous mode stopped\n"
	sleep 1.5
}


function status-boot {
	if [ -f /etc/systemd/system/default.target.wants/anonsurfd.service ]; then
		echo -e "\n$GREEN[$RED!$GREEN] $RED Anonymous mode is$GREEN enabled$RED!$RESETCOLOR\n"
	else
		echo -e "\n$GREEN[$RED!$GREEN] $RED Anonymous is mode disabled!$RESETCOLOR\n"
	fi
}


function enable-boot {
	if [ -f /etc/systemd/system/default.target.wants/anonsurfd.service ]; then
		echo -e "\n$GREEN[$RED!$GREEN] $RED Anoymous mode is already enabled!$RESETCOLOR\n"
	else
		/usr/bin/systemctl enable anonsurfd;
		notify "Enabling anonymous mode at boot"
	fi
}


function disable-boot {
	if [ -f /etc/systemd/system/default.target.wants/anonsurfd.service ]; then
		/usr/bin/systemctl disable anonsurfd;
		notify "Disabling anonymous mode at boot"
	else
		echo -e "\n$GREEN[$RED!$GREEN] $RED Anonymous mode wasn't enabled. Nothing to disable!$RESETCOLOR\n"
	fi
}


function change {
    sudo python3 exit_node_change.py 
    sudo service tor restart
}


function status {
	if [ -f /etc/anonsurf/nyxrc ]; then
		/usr/bin/nyx --config /etc/anonsurf/nyxrc
	else
		/usr/bin/nyx
	fi
}


function dns {
	echo "Please use /usr/bin/dnstool instead"
	/usr/bin/dnstool help
}


case "$1" in
	start)
		checkuid
		if [ "$(systemctl is-active anonsurfd)" = "inactive" ]; then
			zenity --question --text="Do you want to kill dangerous applications and clean some application caches?" --width 400 && kill-apps
			start
		else
			# TODO check "failed" service here
			echo -e "\n$GREEN[$RED!$GREEN] $RED Anonymous mode is running! Can't start service!$RESETCOLOR\n" >&2
		fi
	;;
	
	stop)
		checkuid
		if [ "$(systemctl is-active anonsurfd)" = "active" ]; then
			zenity --question --text="Do you want to kill dangerous applications and clean some application caches?" --width 400 && kill-apps
			stop
		else
			echo -e "\n$GREEN[$RED!$GREEN] $RED Anonymous mode is not running! Can't stop service!$RESETCOLOR\n" >&2
		fi
	;;
	changeid|change-id|change)
		change
	;;
	status)
		if [ "$(service anonsurfd status | grep Active | awk '{print $2}')" = "active" ]; then
			status
		else
			echo -e "\n$GREEN[$RED!$GREEN] $RED Anonymous mode is not running!$RESETCOLOR\n"
		fi
	;;
	myip|ip)
		checkIP
	;;
	dns)
		dns
	;;
	restart)
		checkuid
		if [ "$(service anonsurfd status | grep Active | awk '{print $2}')" = "active" ]; then
			/usr/sbin/service anonsurfd restart
		else
			echo -e "\n$GREEN[$RED!$GREEN] $RED Anonymous mode is not running! Can't restart service!$RESETCOLOR\n" >&2
		fi
	;;
	enable-boot)
		checkuid
		enable-boot
	;;
	disable-boot)
		checkuid
		disable-boot
	;;
	status-boot)
		status-boot
	;;
   *)

echo -e "
$BLUE Anonymous mode command Line Interface$RESETCOLOR
  Usage:
  $RED┌──[$GREEN$USER$YELLOW@$BLUE`hostname`$RED]─[$GREEN$PWD$RED]
  $RED└──╼ \$$GREEN"" exit_node_handling.sh $RED{$GREEN""start$RED|$GREEN""stop$RED|$GREEN""restart$RED|$GREEN""enable-boot$RED|$GREEN""disable-boot$RED|$GREEN""change$RED""$RED|$GREEN""status$RED""}

  $RED start$BLUE -$GREEN Start system-wide tor tunnel
  $RED stop$BLUE -$GREEN Stop anonymous mode and return to clearnet
  $RED restart$BLUE -$GREEN Restart anonymous mode daemon and tor service
  $RED enable-boot$BLUE -$GREEN Enable anonymous mode at boot
  $RED disable-boot$BLUE -$GREEN Disable anonymous mode at boot
  $RED status-boot$BLUE -$GREEN Show if anonymous mode is enabled at boot
  $RED changeid$BLUE -$GREEN Auto change your identify on tor network
  $RED status$BLUE -$GREEN Check if anonymous mode is working properly
  $RED myip$BLUE -$GREEN Check your IP address and verify your tor connection
  $RED dns$BLUE -$GREEN Fast set / fix DNS. Please use /usr/bin/dnstool.
$RESETCOLOR
" >&2

exit 1
;;
esac

echo -e $RESETCOLOR
exit 0
