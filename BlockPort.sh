#!/bin/bash

# Check if port number was passed as argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <port number>"
    exit 1
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
