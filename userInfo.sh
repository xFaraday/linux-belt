#!/bin/bash

# simple functions to acquire specific information about users across entire system


# get last login time for each user in (day month date time timezone year) format using regex
function lastLog() 
{
	users=$(grep 'sh$' /etc/passwd | cut -d: -f1)

    for user in $users; do
        lastLoggedIn=$(lastlog -u $user | grep -Eo '[A-Z][a-z]{2} [A-Z][a-z]{2} [ 0-9][0-9] [0-9]{2}:[0-9]{2}:[0-9]{2}')
    done
} 

# grab numlogons using last command which reads from wtmp for successful logins
function numLogons() 
{
	users=$(grep 'sh$' /etc/passwd | cut -d: -f1)

    for user in $users; do
        logins=$(last -F | grep -vE "(reboot|systemd|wtmp)" | awk '{print $1}' | grep $user | wc -l)
    done
}

# grab num of failed login attempts by using lastb command which reads through btmp for failed login attempts
function badAttempts()
{
	users=$(grep 'sh$' /etc/passwd | cut -d: -f1)

    for user in $users; do
        attempts=$(lastb -F -i -w | awk '{print $1}' | grep $user | wc -l)
    done
}