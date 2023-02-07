#!/bin/bash

GroupsWithSudo=$(grep -E '^%' /etc/sudoers)

for i in $GroupsWithSudo; do
	if [[ $(echo $i | grep -Eo '%') ]]; then
		echo "Group with Sudo permission: $i"
		group=$(echo $i | cut -d'%' -f2)
		users=$(grep -E "^$group" /etc/group)
		userswithsudo=$(echo $users | rev | cut -d':' -f1 | rev)
		echo "Users a part of $group:"
		echo "$userswithsudo"
	fi
done
