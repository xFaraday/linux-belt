#!/bin/bash

# Check if port number was passed as argument
if [ "$EUID" -ne 0 ]; then
        echo 'script requires root privileges'
        exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <port number>"
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

if [ -f "/opt/memento/firewallport.log" ]; then
	if [ $(head -n 1 /opt/memento/firewallport.log) = "reset" ]; then
		echo "blocking $1" >> /opt/memento/firewallport.log
	else
		echo "reset" >> /opt/memento/firewallport.log
		echo "blocking $1" >> /opt/memento/firewallport.log
		iptables -P INPUT ACCEPT
		iptables -P OUTPUT ACCEPT
		iptables -P FORWARD ACCEPT
		iptables -F
		iptables-save
	fi
else
	echo "reset" >> /opt/memento/firewallport.log
	echo "blocking $1" >> /opt/memento/firewallport.log
	iptables -P INPUT ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -F
	iptables-save
fi

# Store the port number
PORT=$1

# Check if the port is already blocked
BLOCKED=$(iptables -L INPUT -n | grep $PORT)
if [ -n "$BLOCKED" ]; then
    echo "The port $PORT is already blocked"
    exit 1
fi

# Block the port
iptables -A INPUT -p tcp --dport $PORT -j DROP
#save
iptables-save

echo "Incoming connections to port $PORT have been blocked"
