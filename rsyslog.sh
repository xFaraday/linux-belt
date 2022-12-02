#!/bin/bash

first='*.* action(type=”omfwd” target=”'
second="$1"
third='” port=”514” protocol=”udp”)'

final="${first}${second}${third}"

var=$(systemctl is-active rsyslog)
if [[ "$var" == "active" || -w /etc/rsyslog.conf ]]; then
	echo "$final" >> /etc/rsyslog.conf
	systemctl enable rsyslog
	systemctl mask rsyslog
else 
	if [ $(command -v apt-get) ]; then # Debian based
    		apt-get install rsyslog -y
		systemctl start rsyslog
		systemctl enable rsyslog
		systemctl mask rsyslog
		echo "$final" >> /etc/rsyslog.conf
	elif [ $(command -v yum) ]; then
    		yum -y install rsyslog
		systemctl start rsyslog
		systemctl enable rsyslog
		systemctl mask rsyslog
		echo "$final" >> /etc/rsyslog.conf
	elif [ $(command -v pacman) ]; then 
    		yes | pacman -S rsyslog
		systemctl start rsyslog
		systemctl enable rsyslog
		systemctl mask rsyslog
		echo "$final" >> /etc/rsyslog.conf
	elif [ $(command -v apk) ]; then # Alpine
    		apk update
    		apk upgrade
    		apk add bash rsyslog
		systemctl start rsyslog
		systemctl enable rsyslog
		systemctl mask rsyslog
		echo "$final" >> /etc/rsyslog.conf
	fi
fi
