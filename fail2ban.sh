#!/bin/bash

#determine operating system

#install fail2ban
if [ $(command -v apt-get) ]; then # Debian based
    apt-get install fail2ban -y 
elif [ $(command -v yum) ]; then
    yum -y install fail2ban
elif [ $(command -v pacman) ]; then 
    yes | pacman -S fail2ban
elif [ $(command -v apk) ]; then # Alpine
    apk update
    apk upgrade
    apk add bash fail2ban
fi

#configure sshd
#sed -i '/^[sshd]*/a enabled=true\nmaxretry=3\nfindtime=20m\nbantime=30m' /etc/fail2ban/jail.conf
function sshdenable() {
    printf "[sshd]
    enabled = true
    port = ssh
    filter = sshd
    logpath = %(sshd_log)s
    backend = %(sshd_backend)s
    maxretry = 3
    bantime = 120
    " > /etc/fail2ban/jail.d/ssh.conf
}

function dropbearenable() {
    printf "[dropbear]
    enabled  = true
    port     = ssh
    logpath  = %(dropbear_log)s
    backend  = %(dropbear_backend)s
    " > /etc/fail2ban/jail.d/dropbear.conf
}

function apacheenable() {
    printf "[apache-auth]
    enabled  = true
    port     = http,https
    logpath  = %(apache_error_log)s
    " > /etc/fail2ban/jail.d/apacheauth.conf
}

function nginxenable() {
    printf "[nginx-http-auth]
    enabled = true
    mode = normal
    port    = http,https
    logpath = %(nginx_error_log)s
    " > /etc/fail2ban/jail.d/nginxauth.conf
}

function webminenable() {
    printf "[webmin-auth]
    enabled = true
    port    = 10000
    logpath = %(syslog_authpriv)s
    backend = %(syslog_backend)s
    " > /etc/fail2ban/jail.d/webmin.conf
}


function proftpdenable() {
    printf "[proftpd]
    enabled  = true
    port     = ftp,ftp-data,ftps,ftps-data
    logpath  = %(proftpd_log)s
    backend  = %(proftpd_backend)s
    " > /etc/fail2ban/jail.d/proftpd.conf
}

function vsftpdenable() {
    printf "[vsftpd]
    enabled  = true
    port     = ftp,ftp-data,ftps,ftps-data
    logpath  = %(vsftpd_log)s
    " > /etc/fail2ban/jail.d/vsftpd.conf
}

function mysqlenable() {
    printf "[mysqld-auth]
    enabled  = true
    port     = 3306
    logpath  = %(mysql_log)s
    backend  = %(mysql_backend)s
    " > /etc/fail2ban/jail.d/mysqlauth.conf
}

function getRuntime() {
    if [ $(which systemctl) ]; then
        printf "systemctl"
    fi
    if [ $(which service) ]; then
        printf "service"
    fi
}

runtime=$(getRuntime)
case "$runtime" in
    "systemctl")
        if [ $(systemctl is-active "sshd") == "active" ]; then
            sshdenable
        fi
        if [ $(systemctl is-active "dropbear") == "active" ]; then
            dropbearenable
        fi
        if [ $(systemctl is-active "apache2") == "active" ]; then
            apacheenable
        fi
        if [ $(systemctl is-active "nginx") == "active" ]; then
            nginxenable
        fi
        if [ $(systemctl is-active "webmin") == "active" ]; then
            webminenable
        fi
        if [ $(systemctl is-active "proftpd") == "active" ]; then
            proftpdenable
        fi
        if [ $(systemctl is-active "vsftpd") == "active" ]; then
            vsftpdenable
        fi
        if [ $(systemctl is-active "mysql") == "active" ]; then
            mysqlenable
        fi
    ;;
    "service")
        if [ $(service status "sshd" | grep -oi "running") == "running" ]; then
            sshdenable
        fi
        if [ $(service status "dropbear" | grep -oi "running") == "running" ]; then
            dropbearenable
        fi
        if [ $(service status "apache2" | grep -oi "running") == "running" ]; then
            apacheenable
        fi
        if [ $(service status "nginx" | grep -oi "running") == "running" ]; then
            nginxenable
        fi
        if [ $(service status "webmin" | grep -oi "running") == "running" ]; then
            webminenable
        fi
        if [ $(service status "proftpd" | grep -oi "running") == "running" ]; then
            proftpdenable
        fi
        if [ $(service status "vsftpd" | grep -oi "running") == "running" ]; then
            vsftpdenable
        fi
        if [ $(service status "mysql" | grep -oi "running") == "running" ]; then
            mysqlenable
        fi
    ;;
esac

systemctl restart fail2ban
systemctl enable fail2ban

fail2ban-client status