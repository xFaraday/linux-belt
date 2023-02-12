#!/bin/bash

# Check if IP address was passed as argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <IP address>"
    exit 1
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
