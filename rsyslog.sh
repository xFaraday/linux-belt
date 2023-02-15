#!/bin/bash

first='*.* action(type=”omfwd” target=”'
second="$1"
third='” port=”514” protocol=”udp”)'

secondfirst='*.* @'
secondsecond="$1"

final="${first}${second}${third}"
secondfinal="${secondfirst}${secondsecond}"

var=$(systemctl is-active rsyslog)
if [[ "$var" == "active" || -w /etc/rsyslog.conf ]]; then
	echo "$secondfinal" >> /etc/rsyslog.conf
	echo "$final" >> /etc/rsyslog.conf
	systemctl unmask rsyslog
	systemctl restart rsyslog
	systemctl enable rsyslog
	systemctl mask rsyslog
else 
	if [ $(command -v apt-get) ]; then # Debian based
    	apt-get install rsyslog -y
		echo "$secondfinal" >> /etc/rsyslog.conf
		echo "$final" >> /etc/rsyslog.conf
		systemctl start rsyslog
		systemctl enable rsyslog
		systemctl mask rsyslog
	elif [ $(command -v yum) ]; then
    		yum -y install rsyslog
		echo "$secondfinal" >> /etc/rsyslog.conf
		echo "$final" >> /etc/rsyslog.conf
		systemctl start rsyslog
		systemctl enable rsyslog
		systemctl mask rsyslog
	elif [ $(command -v pacman) ]; then 
    		yes | pacman -S rsyslog
		echo "$secondfinal" >> /etc/rsyslog.conf
		echo "$final" >> /etc/rsyslog.conf
		systemctl start rsyslog
		systemctl enable rsyslog
		systemctl mask rsyslog
	elif [ $(command -v apk) ]; then # Alpine
    		apk update
    		apk upgrade
    		apk add bash rsyslog
		echo "$secondfinal" >> /etc/rsyslog.conf
		echo "$final" >> /etc/rsyslog.conf
		systemctl start rsyslog
		systemctl enable rsyslog
		systemctl mask rsyslog
	fi
fi
