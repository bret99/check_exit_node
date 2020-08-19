#!/bin/bash

function notify {
    if [ -e /usr/bin/notify-send ]; then
        /usr/bin/notify-send "Your public IP:" "$1"
    fi
}

IP=$(curl ifconfig.me)
countryToFind=`whois $IP|grep country|sed 's/country://; s/Country://'|sort --unique`                                                          
flagToFind=`echo $countryToFind|sed -e 's/\(.*\)/\L\1/'`   
flagToShow=`cd /usr/share/iso-flags-svg/country-4x3/;ls|grep $flagToFind`
MYIP=`whois $IP|grep -E -i "cidr|country|city|address|organization|descr"|sort`
notify "$MYIP\npuplic IP:\t$IP"
sleep 1.0
notify-send "$countryToFind  is your exit node " -i /usr/share/iso-flags-svg/country-4x3/$flagToShow
