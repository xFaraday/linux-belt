#!/bin/bash

# Check if IP address was passed as argument
if [ "$EUID" -ne 0 ]; then
        echo 'script requires root privileges'
        exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <IP address>"
    exit 1
fi

if [ -d "/opt/memento" ]; then
	continue
else 
	mkdir /opt/memento
fi

#file exists
#check if head -n 1 = reset

#if file doesnt exist
#create file and echo "reset" > firewall.log
#then perform block action

if [ -f "/opt/memento/firewallip.log" ]; then
	if [ $(head -n 1 /opt/memento/firewallip.log) = "reset" ]; then
		echo "blocking $1" >> /opt/memento/firewallip.log
	else
		echo "reset" >> /opt/memento/firewallip.log
		echo "blocking $1" >> /opt/memento/firewallip.log
		iptables -P INPUT ACCEPT
		iptables -P OUTPUT ACCEPT
		iptables -P FORWARD ACCEPT
		iptables -F
		iptables-save
	fi
else
	echo "reset" >> /opt/memento/firewallip.log
	echo "blocking $1" >> /opt/memento/firewallip.log
	iptables -P INPUT ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -F
	iptables-save
fi


# Store the IP address
IP=$1

# Check if the IP is already blocked
BLOCKED=$(iptables -L INPUT -n | grep $IP)
if [ -n "$BLOCKED" ]; then
    echo "The IP address $IP is already blocked"
    exit 1
fi

# Block the IP
iptables -A INPUT -s $IP -j DROP
#save
iptables-save

echo "The IP address $IP has been blocked"
