#!/bin/bash

# Define the password to be set for all users

card=$(lshw -class network | grep "logical name:" | sed 's/logical name://' | tail -n 1)
ip4=$(/sbin/ip -o -4 addr list $card | awk '{print $4}' | cut -d/ -f1)
lastoctet=$(echo $ip4 | rev | cut -d'.' -f1 | rev)
# Get a list of all users
new_password="$(hostname)isaslut$lastoctet"

users=$(grep 'sh$' /etc/passwd | cut -d':' -f1)

# Loop through all users
for user in $users; do
  # Change the password for each user
  echo "$user:$new_password" | chpasswd
  echo "Password for $user changed to $new_password"
done