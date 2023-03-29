if [ $(command -v apt-get) ]; then # Debian based
    apt-get install vim git chkrootkit rkhunter clamav clamav-daemon -y 
elif [ $(command -v yum) ]; then
    yum -y install vim git chkrootkit rkhunter clamav clamav-daemon
elif [ $(command -v pacman) ]; then 
    yes | pacman -S vim git chkrootkit rkhunter clamav clamav-daemon
elif [ $(command -v apk) ]; then # Alpine
    apk update
    apk upgrade
    apk add bash vim git chkrootkit rkhunter clamav clamav-daemon
fi