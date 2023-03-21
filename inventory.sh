#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo 'Error: Please run as root'
  exit 1
fi

C=$(printf '\033')
ORANGE="${C}[48;2;255;165;0m"
RED="${C}[1;31m"
WHITE="${C}[1;37m"
BLACK="${C}[1;30m"
SED_RED="${C}[1;31m&${C}[0m"
GREEN="${C}[1;32m"
SED_GREEN="${C}[1;32m&${C}[0m"
YELLOW="${C}[1;33m"
SED_YELLOW="${C}[1;33m&${C}[0m"
SED_RED_YELLOW="${C}[1;31;103m&${C}[0m"
BLUE="${C}[1;34m"
SED_BLUE="${C}[1;34m&${C}[0m"
ITALIC_BLUE="${C}[1;34m${C}[3m"
LIGHT_MAGENTA="${C}[1;95m"
SED_LIGHT_MAGENTA="${C}[1;95m&${C}[0m"
LIGHT_CYAN="${C}[1;96m"
SED_LIGHT_CYAN="${C}[1;96m&${C}[0m"
LG="${C}[1;37m" #LightGray
SED_LG="${C}[1;37m&${C}[0m"
DG="${C}[1;90m" #DarkGray
SED_DG="${C}[1;90m&${C}[0m"
NC="${C}[0m"
UNDERLINED="${C}[5m"
ITALIC="${C}[3m"

print_title(){
  if [ "$DEBUG" ]; then
    END_T2_TIME=$(date +%s 2>/dev/null)
    if [ "$START_T2_TIME" ]; then
      TOTAL_T2_TIME=$(($END_T2_TIME - $START_T2_TIME))
      printf $DG"This check took $TOTAL_T2_TIME seconds\n"$NC
    fi

    END_T1_TIME=$(date +%s 2>/dev/null)
    if [ "$START_T1_TIME" ]; then
      TOTAL_T1_TIME=$(($END_T1_TIME - $START_T1_TIME))
      printf $DG"The total section execution took $TOTAL_T1_TIME seconds\n"$NC
      echo ""
    fi

    START_T1_TIME=$(date +%s 2>/dev/null)
  fi

  title=$1
  title_len=$(echo $title | wc -c)
  max_title_len=100
  rest_len=$((($max_title_len - $title_len) / 2))

  printf ${BLUE}
  for i in $(seq 1 $rest_len); do printf " "; done
  printf "╔"
  for i in $(seq 1 $title_len); do printf "═"; done; printf "═";
  printf "╗"

  echo ""

  for i in $(seq 1 $rest_len); do printf "═"; done
  printf "╣ $GREEN${title}${BLUE} ╠"
  for i in $(seq 1 $rest_len); do printf "═"; done

  echo ""

  printf ${BLUE}
  for i in $(seq 1 $rest_len); do printf " "; done
  printf "╚"
  for i in $(seq 1 $title_len); do printf "═"; done; printf "═";
  printf "╝"
  
  printf $NC
  echo ""
}

print_2title(){
  if [ "$DEBUG" ]; then
    END_T2_TIME=$(date +%s 2>/dev/null)
    if [ "$START_T2_TIME" ]; then
      TOTAL_T2_TIME=$(($END_T2_TIME - $START_T2_TIME))
      printf $DG"This check took $TOTAL_T2_TIME seconds\n"$NC
      echo ""
    fi

    START_T2_TIME=$(date +%s 2>/dev/null)
  fi

  printf ${BLUE}"╔══════════╣ $GREEN$1\n"$NC #There are 10 "═"
}

print_3title(){
  printf ${BLUE}"══╣ $GREEN$1\n"$NC #There are 2 "═"
}

print_list(){
  printf ${BLUE}"═╣ $GREEN$1"$NC #There is 1 "═"
}

print_info(){
  printf "${BLUE}╚ ${ITALIC_BLUE}$1\n"$NC
}

function usage() {
	banner
	printf -- "\n\t-a =  all information\n"
	printf -- "\n\t-e =  SEND TO WEBSERVER. Ex: ./inventory.sh -e <IP> <useragent>\n"
	printf -- "\n\t-v =  host information\n"
	printf -- "\n\t-u =  user information\n"
	printf -- "\n\t-l =  lastlog\n"
	printf -- "\n\t-p =  port information\n"
	printf -- "\n\t-s =  service information\n"
	printf -- "\n\t-c =  cron information\n"
	printf -- "\n\t-g =  log information\n"
	printf -- "\n\t-f =  file information\n"
	printf -- "\n\t-h = help\n"
}

function banner() {
	printf "
                 ${DG}/C.   C\.
                ${BLUE}/SS.   SS\.
               /UUU.   UUU\.
              /SSSS.   SSSS\.
             ${DG}/BBBBB.   BBBBB\.
          /CSUSBCSUSBCSUSBCSUSB\.
        ${BLUE}/CSUSBCSUSBCSUSBCSUSBCSUSBC\.
    /CSUSB${RED}CSUSB${BLUE}CSUSBCSUSBCSUS${RED}BCSUS${BLUE}BCS\.
  \CSUSBCSU${RED}S${WHITE}&&&${RED}U${BLUE}SBCSUSBCSUSB${RED}C${WHITE}&&&${RED}B${BLUE}CSUSBCSU/.
   \CSUSBCSU${RED}S${WHITE}&&&${RED}U${BLUE}SBCSUSBCSU${RED}S${WHITE}&&&${RED}U${BLUE}SBCSUSBC/.
    \CSUSBCSU${RED}S${WHITE}&&&${RED}U${BLUE}SBCSUSBC${RED}S${WHITE}&&&${RED}C${BLUE}SUSBCSUS/.
     \CSUSBCSU${RED}S${WHITE}&&&${RED}U${BLUE}SBCSUS${RED}B${WHITE}&&&${RED}S${BLUE}BCSUSBCS/.
      \CSUSBCSU${RED}S${WHITE}&&&${RED}C${BLUE}SUSB${RED}C${WHITE}&&&${RED}S${BLUE}USBCSUSB/.
       \CSUSBCSU${RED}SBCSU${BLUE}SB${RED}CSUSB${BLUE}CSUSBCSU/.
        \CSUSBCSUSBCSUSBCSUSBCSUSBC/.
              ${RED}\CSUSBCSUSBCSUS${RED}/${DG}.
              ${WHITE}V${RED}\\${DG}CSUSBCSUSBCS${RED}/${WHITE}V${DG}.
               ${WHITE}V${RED}\\${DG}CSUSBCSUSB${RED}/${WHITE}V${DG}.
                ${WHITE}V${RED}\\${DG}CSUSBCSU${RED}/${WHITE}V${DG}.
                 ${WHITE}V${RED}\\${DG}CSUSBC${RED}/${WHITE}V${DG}.
                  ${WHITE}V${RED}\\${DG}CSUS${RED}/${WHITE}V${DG}.${WHITE}=\\${DG}      ~
                   ${WHITE}V${RED}\**/${WHITE}V${DG}.${WHITE}\\==\\${DG}   ~
                           ${WHITE}\\==\\${DG}    ~
                            ${WHITE}\\==\\${DG} ~
                             ${RED}(--)${DG}~~
                             ~\n" 
                           
	printf "\t${RED}   ________________  ______\n${NC}"
	printf "\t${RED}  / ____/ ____/ __ \/ ____/\n${NC}"
	printf "\t${RED} / /   / /   / / / / /\n${NC}"     
	printf "\t${RED}/ /___/ /___/ /_/ / /___\n${NC}"   
	printf "\t${RED}\____/\____/_____/\____/\n${NC}" 

	printf "\n${BLUE}BLUE TEAM INVENTORY\n\n${NC}"
}
function spacer () {
	printf "\n\n${GREEN}############################${NC} $1 ${GREEN}############################${NC}\n\n"
}

function smallspacer () {
	printf "\n\n${GREEN}##############${NC} $1 ${GREEN}##############${NC}\n"
}

function host() {
	host=$(hostname)
	printf "Hostname: $host\n"
	cards=$(lshw -class network | grep "logical name:" | sed 's/logical name://')
	ips=()
	for n in $cards; do
		ip4=$(/sbin/ip -o -4 addr list $n | awk '{print $4}' | cut -d/ -f1)
		printf "Ip: $ip4 Card: $n\n"
		ips+=($ip4)
	done

	section="${BLUE}OS INFORMATION${NC}"
	spacer "$section"

	#host info
	version=$(cat /etc/*rel*)
	printf "$version\n"
	#kernel shit
	kernel=$(uname -a)
	printf "\n\n$kernel\n"
	os_release=$(lsb_release -a)
	printf "\n\n$os_release\n"
}

function user() {
	section="${BLUE}USER INFORMATION${NC}"
	spacer "$section"

	#users
	#cat /etc/passwd | grep -in /bin/bash
	users=$(grep 'sh$' /etc/passwd)
	section="${BLUE}Users that can login${NC}"
	smallspacer "$section"
	#printf "$users"
	for i in $users; do
		u=$(echo $i | cut -d: -f1)
		echo "${RED}$u${NC}"
		printf "\t$i\n"
	done


	if [ -f /etc/sudoers ] ; then
		section="${BLUE}Sudoers File${NC}"
		smallspacer "$section"
		awk '!/#(.*)|^$/' /etc/sudoers
	fi 

	#if ! [ -z "grep sudo /etc/group" ]; then
	#	section="${BLUE}Users in sudo group${NC}"
	#	smallspacer "$section"
	#	grep -Po '^sudo.+:\K.*$' /etc/group
	#	section="${BLUE}Users in admin group${NC}"
	#	smallspacer "$section"
	#	grep -Po '^admin.+:\K.*$' /etc/group
	#	section="${BLUE}Users in wheel group${NC}"
	#	smallspacer "$section"
	#	grep -Po '^wheel.+:\K.*$' /etc/group
	#fi
	GroupsWithSudo=$(grep -E '^%' /etc/sudoers)
	
	section="${BLUE}Groups in Sudoers File${NC}"
	smallspacer "$section"

	for i in $GroupsWithSudo; do
		if [[ $(echo $i | grep -Eo '%') ]]; then
			echo "Group with Sudo permission: ${RED}$i${NC}"
			group=$(echo $i | cut -d'%' -f2)
			users=$(grep -E "^$group" /etc/group)
			userswithsudo=$(echo $users | rev | cut -d':' -f1 | rev)
			printf "\tUsers a part of $group:\n"
			printf "\t${RED}$userswithsudo${NC}\n"
		fi
	done
}

function login() {
	section="${BLUE}Login Information${NC}"
	smallspacer "$section"

	#printf "$(lastlog)\n\n"

	printf "$(w)\n\n"
}

function DiscoverListenerTool() {
	if [ $(which lsof) ]; then
		printf "lsof"
		exit 0
	fi
	if [ $(which netstat) ]; then
		printf "netstat"
		exit 0
	fi
	if [ $(which ss) ]; then
		printf "ss"
		exit 0
	fi
}

function ports() {
	if [  -z "$1" ]; then
		section="${BLUE}LISTENING CONNECTIONS${NC}"
		spacer "$section"
		ports=$(lsof -i -P -n | grep LISTEN)
		printf "$ports"
	fi

	function motherprocess() {
		tmp=$1
		tmpname=""
		until [[ $tmp -eq 1 || $tmpname == "systemd" ]]; do
			reg=$tmp
			tmp=$(ps -o ppid= -p $reg)
			tmpname=$(ps -fp $tmp | awk '{print $8}' | tail -n 1 | rev | cut -d '/' -f1 | rev | grep -Eo '[sS]ystemd')
		done
		cmd=$(ps -fp $reg | awk '{print $8}')
		if [[ ! -z "$1" ]]; then
			last=$(echo $cmd | tail -n 1 | awk {'print $2'})
			printf "\"service\":\"$last\"},"
		else
			printf "Master process ID: $reg\n $cmd\n"
		fi
	}

	listeningtool=$(DiscoverListenerTool)

	case "$listeningtool" in
		"lsof")
			portlisten=$(lsof -i -P -n | grep LISTEN | awk '{print $9}' | cut -d':' -f2- | sort -u)
			for i in $portlisten; do
				tmp=$(expr $i + 1 2>/dev/null)
				if [ $? == 2 ]; then
					printf "\n"
				else
					if [[ ! -z "$1" ]]; then
						var=$(lsof -iTCP:$i -sTCP:LISTEN | awk '{print $2}' | tail -n1)
						printf "{\"port\":$i,"
						motherprocess "$var"
					else
						var=$(lsof -iTCP:$i -sTCP:LISTEN | awk '{print $2}' | tail -n1)
						printf "\nPort: ${RED}$i${NC} Owning process: $var \n"
						motherprocess "$var"
					fi	
				fi
			done
			;;
		"netstat")
			var=$(netstat -l -p -n -t -d -e | grep -v "tcp6" | grep "^tcp" | awk '{print $4}')
			for i in $var; do
				portfromcut=$(echo $i | cut -d':' -f2)
				tmp=$(expr $i + 1 2>/dev/null)
				if [ $? == 2 ]; then
					printf "\n"
				else
					if [[ ! -z "$1" ]]; then
						var=$(fuser $portfromcut/tcp 2>/dev/null)
						printf "{\"port\":$portfromcut,"
						motherprocess "$var"
					else
						var=$(fuser $portfromcut/tcp 2>/dev/null)
						printf "\nPort: ${RED}$portfromcut${NC} Owning process: $var \n"
						motherprocess "$var"
					fi	
				fi
			done
			;;
		"ss")
			var=$(ss -tlpn -4 | grep LISTEN)
			while read -r line; do
				# Extract listening port and PID using awk
				port=$(echo "$line" | awk '{print $4}')
				pid=$(echo "$line" | awk -F'[=,]' '{print $3}')

				if [[ ! -z "$1" ]]; then
					printf "{\"port\":$port,"
					motherprocess "$pid"
				else
					printf "\nPort: ${RED}$port${NC} Owning process: $pid \n"
					motherprocess "$pid"
				fi
			done <<< "$ss_output"
			;;
	esac
	#ports
	#find open ports lsof -i -P -n | grep LISTEN | awk '{print $9}' | cut -d':' -f2-
}
#put those ports into lsof -iTCP:53 -sTCP:LISTEN to find process
#ps -o ppid= -p pid
#ps -fp PID find some way to parse the ps output to get the full command alone maybe

#firewall
#either learn how to read iptables or just figure out a way to make it easy to read

#services
#systemctl is-active --quiet service && echo Service is running

function service() {
	if [  -z "$1" ]; then
		section="${BLUE}SERVICES${NC}"
		spacer "$section"
	fi
	runningservs=()
	essentials=("ssh" "sshd" "apache" "apache2" "httpd" "smbd" "vsftpd" "mysql" "postgresql" "vncserver" "xinetd" "telnetd" "webmin" "cups" "ntpd" "snmpd" "dhcpd" "ipop3" "postfix" "rsyslog" "docker" "samba" "postfix" "smtp" "psql" "clamav" "bind9" "nginx" "mariadb" "ftp")
	for i in ${essentials[@]}; do
		var=$(systemctl is-active $i)
		if [ "$var" == "active" ]; then
			secvar=$(systemctl is-enabled $i)
			if [ "$secvar" == "enabled" ]; then
				if [[ ! -z "$1" ]]; then
					printf "$i\n"
				else
					printf "Service: ${RED}$i${NC} is running and enabled!\n"
					loc=$(ls /etc | grep $i)
					printf "\t Likely config files: /etc/$loc\n"
				fi
			else
				if [[ ! -z "$1" ]]; then
					printf "$i\n"
				else
					printf "Service: ${RED}$i${NC} is running!\n"
					loc=$(ls /etc | grep $i)
					printf "\t Likely config files: /etc/$loc\n"
					runningservs+=("$i")
				fi
			fi
		fi
	done
	serviceslong=$(systemctl --type=service --state=active)
}

function cron() { 
	section="${BLUE}CRONTAB${NC}"
	spacer "$section"

	section="${BLUE}System Cronjobs${NC}"
	smallspacer "$section"

	crontab -l

	section="${BLUE}User Cronjobs${NC}"
	smallspacer "$section"

	users=$(grep 'sh$' /etc/passwd | cut -d':' -f1)
	for user in $users; do
		crontab -l -u $user
	done
}


function log() {
	section="${BLUE}LOGS${NC}"
	spacer "$section"
	# Use the find command to search for files recursively
	
	#HANGING FOR SOME REASON BRUH
	#files=$(find /var/log -type f)
	#for i in $files; do
	#	type=$(file "$i" | awk -F: '{print $2}')
		# Check if the file is a regular file and if it contains ASCII text
	#	if [ -f $i ] && [[ "$type" == *"ASCII text"* ]]; then
		#NameOfFile=$(echo $file | rev | cut -d'/' -f1 | rev)
		#printf "\t${RED}$NameOfFile${NC}\n"
		#printf "\t\t$file\n\n"
	#		echo "$i"
	#	fi
	#done	
}

function dockerenum() {

	runnin=$(docker ps)

	images=$(docker images)
	section="${BLUE}currently running${NC}"
	smallspacer "$section"
	printf -- "$runnin\n\n"
	section="${BLUE}images installed${NC}"
	smallspacer "$section"
	printf -- "$images\n\n"

}

function file() {
	section="${BLUE}FILES${NC}"
	spacer "$section"

	#add file section
	scriptsinhome=$(find /home -daystart -mtime -2 -name '*.sh' -type f -exec ls -l {} \; 2>/dev/null)

	printf -- "$scriptsinhome"
	printf "\n\n"
}

##########################################
#					                     #
#	         new functions               #
#					                     #
#########################################

function UserAdminCheck() {
	user=$1
	#check if user is in sudoers
	grep "^$user" /etc/sudoers 1>/dev/null
	if [ $? == 0 ]; then
		printf "true"
		exit 0
	fi
	#check if user is in admin group
	for i in $(grep -E '^%' /etc/sudoers); do
		if [[ $(echo $i | grep -Eo '%') ]]; then
			group=$(echo $i | cut -d'%' -f2)
			users=$(grep -E "^$group" /etc/group)
			userswithsudo=$(echo $users | rev | cut -d':' -f1 | rev)
			if [[ $(echo $userswithsudo | grep "$user") ]]; then
				printf "true"
				exit 0
			fi
		fi
	done
	printf "false"
}

function LockedCheck() {
	lockedpre=$(echo "$1" | grep "nologin" 1>/dev/null && echo -n "true") 
	lockedpre2=$(echo "$1" | cut -d':' -f2 | grep "*" 1>/dev/null && echo -n "true")	
	if [[ "$lockedpre" == "true" ]] || [[ "$lockedpre2" == "true" ]]; then
		echo -n "true"
	else
		echo -n "false"
	fi
}

function PasswdExpiredCheck() {
	if [[ $(which chage) ]]; then
		passwdexpires=$(chage -l $1 | grep "Password expires" | cut -d':' -f2)
		if [[ $(echo $passwdexpires | grep "never") ]]; then
			echo -n "false"
		else
			echo -n "true"
		fi
	fi
	
	# ADD this l8er bb girl
	#
	#grep "$1" /etc/shadow | cut -d':' -f8 | grep "99999" 1>/dev/null
	#if [[ "$passwdage" == "99999" ]]; then
	#	echo -n "true"
	#else
	#	echo -n "false"
	#fi
}

function LastPassChangeCheck() {
	if [[ $(which chage) ]]; then
		lastpasschange=$(chage -l $1 | grep "Last password change" | cut -d':' -f2)
		echo -n "$lastpasschange"
	fi
	# ADD this l8er bb girl
	#
	#grep "$1" /etc/shadow | cut -d':' -f8 | grep "99999" 1>/dev/null
	#if [[ "$passwdage" == "99999" ]]; then
	#	echo -n "true"
	#else
	#	echo -n "false"
	#fi
}

function CompileUserInfo() {
	#For CCDC user stuff:
        # Username ✓
        # Fullname ✓
        # Enabled ✓
        # Locked ✓
        # Admin ✓
        # Passwdexpired ✓
        # CantChangePasswd null
        # Passwdage ✓
        # Lastlogon ✓
        # BadPasswdAttempts null<right now>
        # NumofLogons ✓

	userinfoblock=""
	users=$(cat /etc/passwd | tr ' ' '-')
	for i in $users; do
			#username
			username=$(echo "$i" | cut -d':' -f1)
			userinfoblock+="{\"Username\":\"$username\","
			#fullname
			realname=$(echo "$i" | cut -d':' -f5)
			userinfoblock+="\"Fullname\":\"$realname\","
			#enabled
			enabledpre=$(echo "$i" | grep 'sh$' 1>/dev/null && echo -n "true" || echo -n "false")
			userinfoblock+="\"Enabled\":$enabledpre,"
			#locked
			locked=$(LockedCheck "$i")
			userinfoblock+="\"Locked\":$locked,"

			adminstatus=$(UserAdminCheck $username)
			userinfoblock+="\"Admin\":$adminstatus,"

			passwdexpired=$(PasswdExpiredCheck $username)
			userinfoblock+="\"Passwdexpired\":$passwdexpired,"
			
			userinfoblock+="\"CantChangePasswd\":false,"

			lastpasschange=$(LastPassChangeCheck $username)
			userinfoblock+="\"Passwdage\":\"$lastpasschange\","

			#lastlog
			lastlogdate=$(lastlog -u $username | awk '{ s = ""; for (i=4; i <= NF; i++) s = s $i " "; print s }' | tail -n 1)
			userinfoblock+="\"Lastlogon\":\"$lastlogdate\","
			
			userinfoblock+="\"BadPasswdAttempts\":\"null\","

			#login count
			logincount=$(last $i | grep $i | wc -l)
			userinfoblock+="\"NumofLogons\":\"$logincount\"},"
	done
	echo -n "$userinfoblock"
}

GetOS() {
	if [ -x $(which hostnamectl) ]; then
		OS=$(hostnamectl | grep "Operating System" | cut -d':' -f2)
		OS+=" $(hostnamectl | grep "Kernel" | cut -d':' -f2)"
		printf "$OS"
	else
		OS=$(cat /etc/*-release | grep PRETTY_NAME | cut -d'=' -f2)
		OS+=" $(uname -r)"
		printf "$OS"
	fi
}

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

GetUsers() {
	users=$(grep 'sh$' /etc/passwd)
	names=$(echo $users | cut -d':' -f1)
	uid=$(echo $users | cut -d':' -f3)
	length=$(echo $users | wc -l)
}

function dockercheck() {
	section="${BLUE}DOCKER${NC}"
	spacer "$section"

	if [ -x "$(command -v Docker)" ]; then
  		echo 'Error: Docker is not installed.'
  		return 1
  	else 
  		echo 'Docker installed'
  		dockerenum
  		return 0
	fi
}

PostToServ() {
	webserv="$ip:10000/api/v1/common/inventory"
	postdata=$1
	echo $postdata | jq 
	if [ -x $(which curl) ]; then
		#add custom user agent
		curl -H 'Content-Type: application/json' -H "User-Agent: $useragent" -d "$postdata" https://${webserv} --insecure
	else 
		wget --post-data "$postdata" --user-agent "$useragent" https://${webserv} --no-check-certificate
	fi
}

DSuck() {
	#or docker ps --format "{{.ID}}"
	docinfo=""
	for i in $(docker ps | awk '{print $1}' | grep -vi "container"); do
		jname=$(docker inspect --format='{{.Config.Image}}' $i)
		jstatus=$(docker inspect --format='{{.State.Status}}' $i)
		jhealth=$(docker inspect --format='{{.State.Health.Status}}' $i)
		jID=$(echo $i)
		cmds=$(docker inspect --format='{{.Config.Cmd}}' $i)
		jcmds=$(echo ${cmds::-1} | cut -b 2-)
		ports=$(docker inspect --format='{{.NetworkSettings.Ports}}' $i)
		jports=$(echo ${ports::-1} | cut -b 5-)
		docinfo+="{\"name\":\"$jname\",\"status\":\"$jstatus\",\"health\":\"$jhealth\",\"id\":\"$jID\",\"cmd\":\"$jcmds\",\"ports\":\"$jports\"},"
	done
	echo -n "$docinfo"
}

function PrepareArrays() {
	if [[ $(echo -e "$1" | wc -l) -gt 0 ]]; then
		printf "${1::-1}"
	else 
		printf "$1"
	fi
}

function ExportToJSON() {
	OS=$(GetOS)
	IP=""
	IPS=$(GetIP $ip)
	#if [[ $(echo $IPS | wc -l) -gt 1 ]]; then
	#	for i in $IPS; do
	#		IP+="$i-:-"
	#	done
	#	IP=$IPS
	#fi

	printf "\n\n${BLUE}Exporting to JSON...\n\n${NC}"
	#json format with or without docker containers
	which docker 1>/dev/null 2>&1 && JSON='{"name":"%s","hostname":"%s","ip":"%s","OS":"%s","services":[%s], "containers":[%s], "users": [%s]}' || JSON='{"name":"%s","hostname":"%s","ip":"%s","OS":"%s","services":[%s], "users": [%s]}'


	#FOR SHARES JUST WAIT TO SEE IF PARSING CAN BE DIFFERENT FOR LINUX
	#then just grep through /etc/samba/smb.conf and smbclient tools

	hostname=$(hostname)
	nameIP=$(echo $IPS | rev | cut -d '.' -f1 | rev)
	name="host-$nameIP"
	services=$(ports "json")
	checkedservices=$(PrepareArrays $services)
	userinfo=$(CompileUserInfo)
	which docker 1>/dev/null 2>&1 && containerinfo=$(DSuck)
	checkedcontainerinfo=$(PrepareArrays $containerinfo)
	#echo -e "${services::-1}\n\n"
	postdata=$(printf "$JSON" "$name" "$hostname" "$IPS" "$OS" "${checkedservices}" "${userinfo::-1}")
	echo $postdata
	PostToServ "$postdata"
}

#banner
ip=$2
useragent=$3
#ExportToJSON

while getopts 'banner:host:user:login:ports:services:cron:log:file:all:ExportToJSON:CompileUserInfo' option; do
	case "$option" in
		b)banner; exit 0 ;;
		v)host; exit 0 ;;
		u)user; exit 0 ;;
		l)login; exit 0 ;;
		p)ports; exit 0 ;;
		s)service; exit 0 ;;
		c)cron; exit 0 ;;
		o)dockercheck; exit 0 ;;
		g)log; exit 0 ;;
		f)file; exit 0 ;;
		e)ExportToJSON; exit 0 ;;
		a)a= banner; host; user; login; ports; service; cron; dockercheck; log; file; exit 0 ;;
		i)CompileUserInfo; exit 0 ;;
		h) usage; exit 0 ;;
	esac
done

if [[ "$#" -eq 0 ]]; then
	usage
	exit 0
fi
