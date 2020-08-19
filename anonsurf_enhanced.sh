#!/bin/bash

# anonsurf is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# You can get a copy of the license at www.gnu.org/licenses
#
# anonsurf is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Parrot Security OS. If not, see <http://www.gnu.org/licenses/>.


export BLUE='\033[1;94m'
export GREEN='\033[1;92m'
export RED='\033[1;91m'
export RESETCOLOR='\033[1;00m'

function notify {
	# Use system notification to show popup and let user know latest changes
	if [ -e /usr/bin/notify-send ]; then
		/usr/bin/notify-send "AnonSurf" "$1"
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
	# Kill some network app that can have sensitive data
	echo -e -n "$BLUE[$GREEN*$BLUE] killing dangerous applications\n"
	sudo killall -q chrome dropbox skype icedove thunderbird firefox firefox-esr chromium xchat hexchat transmission steam firejail
	echo -e -n "$BLUE[$GREEN*$BLUE] Dangerous applications killed\n"

	echo -e -n "$BLUE[$GREEN*$BLUE] cleaning some dangerous cache elements\n"
	bleachbit -c adobe_reader.cache chromium.cache chromium.current_session chromium.history elinks.history emesene.cache epiphany.cache firefox.url_history flash.cache flash.cookies google_chrome.cache google_chrome.history  links2.history opera.cache opera.search_history opera.url_history &> /dev/null
	echo -e -n "$BLUE[$GREEN*$BLUE] Cache cleaned\n"
        sleep 1.5
}

function checkIP {
	# Get current public IP address and isConnectToTor status
	DATA=`curl --socks5 localhost:9050 --socks5-hostname localhost:9050 -s https://check.torproject.org/`
        IP=$(curl ifconfig.me)
        countryToFind=`whois $IP|grep ountry|sed 's/country://; s/Country://'|head -n 1`                                                          
        flagToFind=`echo $countryToFind|sed -e 's/\(.*\)/\L\1/'`   
        flagToShow=`cd /usr/share/icons/mate/scalable/animations/;ls|grep $flagToFind`
        if [ "$flagToShow" == ""  ]
        then countryFlag=""
        else countryFlag=/usr/share/icons/mate/scalable/animations/$flagToShow
        fi
        MYIP=`whois $IP|grep -E -i "country|city|address|organization|descr"|sort --unique | tail -n 10`
	if [ "$DATA" != "" ]; then
#		IP=`echo $DATA | grep -E -o "<strong>(\S+)</strong>" | sed -e 's/<[^>]*>//g'`
                notify2 $countryToFind $countryFlag "You are connected to Tor network\n\n$MYIP\npublic IP:\t$IP"
	else
#		IP=`curl -s https://check.torproject.org/ | grep -E -o "<strong>(\S+)</strong>" | sed -e 's/<[^>]*>//g'`
		if [ "$IP" == "" ]; then
			notify "Can't connect to internet\nPlease check your settings"
		else
                    notify2 $countryToFind $countryFlag "You are NOT connected to Tor network\n\n$MYIP\npublic IP:\t$IP" 
		fi
	fi
}


function checkuid {
	# Make sure only root can run this script
	ME=$(whoami | tr [:lower:] [:upper:])
	if [ $(id -u) -ne 0 ]; then
		echo -e "\n$GREEN[$RED!$GREEN] $RED $ME R U DRUNK?? This script must be run as root$RESETCOLOR\n" >&2
		exit 1
	fi
}


function start {
	# Start Tor and then AnonSurf daemon
	echo -e "\n$GREEN[$BLUE i$GREEN ]$BLUE Starting anonymous mode:$RESETCOLOR\n"

	echo -e "$GREEN *$BLUE Generating AnonSurf session"
	/usr/sbin/service anonsurfd start

	echo -e "$GREEN *$BLUE Starting tor service"
	# /usr/sbin/service tor start

	echo -e "$GREEN *$BLUE All traffic was redirected throught Tor\n"
	echo -e "$GREEN[$BLUE i$GREEN ]$BLUE You are under AnonSurf tunnel$RESETCOLOR\n"
	sleep 1.5
}


function stop {
	# Stop Tor and AnonSurf daemon
	echo -e "\n$GREEN[$BLUE i$GREEN ]$BLUE Stopping anonymous mode:$RESETCOLOR\n"

	# /usr/sbin/service tor stop
	/usr/sbin/service anonsurfd stop

	echo -e " $GREEN*$BLUE Anonymous mode stopped\n"
	sleep 1.5
}


function status-boot {
	# Show if AnonSurf is enabled at boot
	# Systemd makes a symlink to start it on boot
	# we simple check symlink instead of calling sysctl to checks
	if [ -f /etc/systemd/system/default.target.wants/anonsurfd.service ]; then
		echo -e "\n$GREEN[$RED!$GREEN] $RED AnonSurf is$GREEN enabled$RED!$RESETCOLOR\n"
	else
		echo -e "\n$GREEN[$RED!$GREEN] $RED AnonSurf is disabled!$RESETCOLOR\n"
	fi
}


function enable-boot {
	# if [ "$(systemctl list-unit-files | grep anonsurfd | awk '{print $2}')" = "disabled" ]; then
	# New method: Check if symlink file at /lib/systemd/system/anonsurfd.service is there
	# If file is there -> systemctl enabled anonsurf at boot
	
	# BUG: The folder default.target.wants is defined by target in sys unit file
	# Any change of that section creates bug in this condition

	# Check if symlink doesn't exists -> we enable it
	if [ -f /etc/systemd/system/default.target.wants/anonsurfd.service ]; then
		echo -e "\n$GREEN[$RED!$GREEN] $RED AnonSurf already enabled!$RESETCOLOR\n"
	else
		/usr/bin/systemctl enable anonsurfd;
		notify "Enabling AnonSurf at boot"
	fi
}


function disable-boot {
	# New method: Check if symlink file at /lib/systemd/system/anonsurfd.service is there
	# If file is there -> systemctl enabled anonsurf at boot
	# if [ "$(systemctl list-unit-files | grep anonsurfd | awk '{print $2}')" = "enabled" ]; then
	if [ -f /etc/systemd/system/default.target.wants/anonsurfd.service ]; then
		/usr/bin/systemctl disable anonsurfd;
		notify "Disabling AnonSurf at boot"
	else
		echo -e "\n$GREEN[$RED!$GREEN] $RED AnonSurf wasn't enabled. Nothing to disable!$RESETCOLOR\n"
	fi
}


function change {
    sudo python3 /home/desktop/my_opt/exit_node_change.py 
    sudo service tor restart
}


function status {
	# Show current Tor status by calling nyx
	if [ -f /etc/anonsurf/nyxrc ]; then
		# When AnonSurf is enabled, we create a nyxrc which contains
		# our random cleartext password
		# So we can call nyx without adding password
		/usr/bin/nyx --config /etc/anonsurf/nyxrc
	else
		/usr/bin/nyx
	fi
}


function dns {
	# DNSTool suggestion
	echo "Please use /usr/bin/dnstool instead"
	/usr/bin/dnstool help
}


# Start checking user options from cli
case "$1" in
	start)
	# Only start if anonsurfd is not running
		checkuid
		if [ "$(systemctl is-active anonsurfd)" = "inactive" ]; then
			zenity --question --text="Do you want AnonSurf to kill dangerous applications and clean some application caches?" --width 400 && kill-apps
			start
		else
			# TODO check "failed" service here
			echo -e "\n$GREEN[$RED!$GREEN] $RED AnonSurf is running! Can't start service!$RESETCOLOR\n" >&2
		fi
	;;
	
	stop)
	# Only stop if the anonsurfd is running
		checkuid
		if [ "$(systemctl is-active anonsurfd)" = "active" ]; then
			zenity --question --text="Do you want AnonSurf to kill dangerous applications and clean some application caches?" --width 400 && kill-apps
			stop
		else
			echo -e "\n$GREEN[$RED!$GREEN] $RED AnonSurf is not running! Can't stop service!$RESETCOLOR\n" >&2
		fi
	;;
	changeid|change-id|change)
		change
	;;
	status)
		if [ "$(service anonsurfd status | grep Active | awk '{print $2}')" = "active" ]; then
			status
		else
			echo -e "\n$GREEN[$RED!$GREEN] $RED AnonSurf is not running!$RESETCOLOR\n"
		fi
	;;
	myip|ip)
		checkIP
	;;
	dns)
		dns
	;;
	restart)
		# Restart if the daemon is running onnly
		checkuid
		if [ "$(service anonsurfd status | grep Active | awk '{print $2}')" = "active" ]; then
			/usr/sbin/service anonsurfd restart
			# Should restart with anonsurfd
			# /usr/sbin/service tor restart
		else
			echo -e "\n$GREEN[$RED!$GREEN] $RED AnonSurf is not running! Can't restart service!$RESETCOLOR\n" >&2
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

# This is help banner
echo -e "
AnonSurf [v2.13.9] -$BLUE Command Line Interface$RESETCOLOR

 $RED Developed$RESETCOLOR by$GREEN Lorenzo \"Palinuro\" Faletra$BLUE <palinuro@parrotsec.org>$RESETCOLOR
   $GREEN Lisetta \"Sheireen\" Ferrero$BLUE <sheireen@parrotsec.org>$RESETCOLOR
   $GREEN Francesco \"Mibofra\" Bonanno$BLUE <mibofra@parrotsec.org>$RESETCOLOR
 $RED Maintained$RESETCOLOR by$GREEN Nong Hoang \"DmKnght\" Tu$BLUE <dmknght@parrotsec.org>$RESETCOLOR
    and a huge amount of Caffeine, Mountain Dew + some GNU/GPL v3 stuff
  Extended by Daniel \"Sawyer\" Garcia <dagaba13@gmail.com>

  Usage:
  $RED┌──[$GREEN$USER$YELLOW@$BLUE`hostname`$RED]─[$GREEN$PWD$RED]
  $RED└──╼ \$$GREEN"" anonsurf $RED{$GREEN""start$RED|$GREEN""stop$RED|$GREEN""restart$RED|$GREEN""enable-boot$RED|$GREEN""disable-boot$RED|$GREEN""change$RED""$RED|$GREEN""status$RED""}

  $RED start$BLUE -$GREEN Start system-wide Tor tunnel
  $RED stop$BLUE -$GREEN Stop AnonSurf and return to clearnet
  $RED restart$BLUE -$GREEN Restart AnonSurf daemon and Tor service
  $RED enable-boot$BLUE -$GREEN Enable AnonSurf at boot
  $RED disable-boot$BLUE -$GREEN Disable AnonSurf at boot
  $RED status-boot$BLUE -$GREEN Show if AnonSurf is enabled at boot
  $RED changeid$BLUE -$GREEN Auto change your identify on Tor network
  $RED status$BLUE -$GREEN Check if AnonSurf is working properly
  $RED myip$BLUE -$GREEN Check your IP address and verify your Tor connection
  $RED dns$BLUE -$GREEN Fast set / fix DNS. Please use /usr/bin/dnstool.
$RESETCOLOR
Dance like no one's watching. Encrypt like everyone is.
" >&2

exit 1
;;
esac

echo -e $RESETCOLOR
exit 0
