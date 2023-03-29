#! /bin/bash

if [ $(command -v apt-get) ]; then # Debian based
    apt-get install auditd -y 
elif [ $(command -v yum) ]; then
    yum -y install auditd
elif [ $(command -v pacman) ]; then 
    yes | pacman -S auditd
elif [ $(command -v apk) ]; then # Alpine
    apk update
    apk upgrade
    apk add bash auditd
fi

if grep -q "logz" /etc/audit/rules.d/audit.rules
then
    echo "lol"
else
echo -e "-w /tmp -pxa -k logz\n-w /var/tmp -pxa -k logz\n-w /dev/shm -pxa -k logz\n-w /var/www -prwxa -k logz\n-w /etc/group -pwa -k logz\n-w /etc/pam.d -pwa -k logz\n-w /etc/passwd -pwa -k logz\n-w /etc/shadow -prwa -k logz\n-w /etc/sudoers -pwa -k logz\n-w /etc/sudoers.d -pwa -k logz\n-w /run/usys -prwxa -k logz\n-w /var/spool/cron -prwxa -k logz\n-w /etc/ssh/ssh_config -prwxa -k logz\n-w /etc/ssh/sshd_config -prwxa -k logz\n-w /etc/skel/.bashrc -prwxa -k logz\n-w /etc/rc.local -prwxa -k logz\n-w /etc/init.d -prwxa -k logz\n-w /etc/cron.deny -prwxa -k logz\n-w /etc/crontab -prwxa -k logz\n-w /etc/cron.daily -prwxa -k logz\n-w /etc/cron.hourly -prwxa -k logz\n-w /etc/cron.weekly -prwxa -k logz\n-w /etc/cron.monthly -prwxa -k logz\n-w /etc/anacrontab -prwxa -k logz\n-w /etc/cron.d -prwxa -k logz\n-w /etc/exports -prwxa -k logz\n-w /var/spool/cron -prwxa -k logz\n-w /var/spool/cron/crontab -prwxa -k logz\n-w /usr/bin/python -prwxa -k logz\n-w /usr/bin/python2 -prwxa -k logz\n-w /usr/bin/python2.7 -prwxa -k logz\n-w /usr/bin/python3 -prwxa -k logz\n-w /usr/bin/nc -prwxa -k logz\n-w /usr/bin/id -px -k logz\n-w /usr/bin/whoami -px -k logz\n-w /root/.ssh -prwxa -k logz\n-w /root/.bashrc -prwxa -k logz\n-w /root/.profile -prwxa -k logz\n-w /root/.bash_profile -prwxa -k logz" >> /etc/audit/rules.d/audit.rules
fi
chmod 0750 /sbin/audispd

service auditd restart
systemctl restart auditd
service auditd status
systemctl restart status