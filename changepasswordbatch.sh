#!/bin/bash

# Define the password to be set for all users
users=$(grep 'sh$' /etc/passwd | cut -d':' -f1)

# Loop through all users
printf "\n\n"
printf "===========================================================================\n"
printf "========================       PASSWORD CHANGE      =======================\n"
printf "===========================================================================\n"
printf "\n\n"

GetIP() {
  ipreg=$(echo $1 | cut -d'.' -f1-3)
  if [[ -z $(which lshw) ]]; then
    ip4=$(ip -brief a 2>/dev/null | grep -E "$ipreg" | awk '{print $3}' | cut -d'/' -f1 || ifconfig 2>/dev/null | grep -E "$ipreg" | awk '{print $2}')
    printf "$ip4"
    exit 0
  else 
    cards=$(lshw -class network | grep "logical name:" | sed 's/logical name://')
    for n in $cards; do
      ip4=$(/sbin/ip -o -4 addr list $n | awk '{print $4}' | cut -d/ -f1)
      echo -n $ip4 | grep -E "$ipreg" 2>/dev/null 
    done
    exit 0
  fi
}

if [[ "$#" -eq 0 ]]; then
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
else
  token=$1
  actualip=$(GetIP $2)
  lastoctect=$(echo $actualip | cut -d'.' -f4)
  num=$((token * lastoctect))
  echo "username,password" > users.csv

  for user in $users; do
    new_password="$(hostname)isacoolguy!${num}"
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
fi

