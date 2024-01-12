printf '# Configuration file for my watchlog service
# Place it to /etc/sysconfig
# File and word in that file that we will be monit
WORD="ALERT"
LOG=/var/log/watchlog.log%s\n' > /etc/sysconfig/watchlog

cp /var/log/messages /var/log/watchlog.log

echo "ALERT" >> /var/log/watchlog.log

printf '#!/bin/bash

WORD=$1
LOG=$2
DATE=`date`

if grep $WORD $LOG &> /dev/null
then
logger "$DATE: I found word, Master!"
else
exit 0
fi' > /opt/watchlog.sh


chmod +x /opt/watchlog.sh


printf '[Unit]
Description=My watchlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh $WORD $LOG' > /etc/systemd/system/watchlog.service


printf '[Unit]
Description=Run watchlog script every 30 second

[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/watchlog.timer

yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y

sudo cat /dev/null > /etc/sysconfig/spawn-fcgi

printf '# You must set some working options before the "spawn-fcgi" service will work.
# If SOCKET points to a file, then this file is cleaned up by the init script.
#
# See spawn-fcgi(1) for all possible options.
#
# Example :
SOCKET=/var/run/php-fcgi.sock
OPTIONS="-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi"' > /etc/sysconfig/spawn-fcgi

printf '[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/spawn-fcgi.service

sudo cat /dev/null > /usr/lib/systemd/system/httpd.service

printf '[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service

After=network.target remote-fs.target nss-lookup.target httpd-
init.service

Documentation=man:httpd.service(8)

[Service]
Type=notify
Environment=LANG=C
EnvironmentFile=/etc/sysconfig/httpd-
ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true

[Install]
WantedBy=multi-user.target' > /usr/lib/systemd/system/httpd.service

sed -i 's/httpd-/httpd-%I/' /usr/lib/systemd/system/httpd.service

printf '# /etc/sysconfig/httpd-first
OPTIONS=-f conf/first.conf' > /etc/sysconfig/httpd-first

printf '# /etc/sysconfig/httpd-second
OPTIONS=-f conf/second.conf' > /etc/sysconfig/httpd-second


cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/first.conf

cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/second.conf

echo "PidFile /var/run/httpd-second.pid" >> /etc/httpd/conf/second.conf
sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/second.conf



sudo systemctl start watchlog
sudo systemctl start watchlog.timer
sudo systemctl start spawn-fcgi
sudo systemctl start httpd@first
sudo systemctl start httpd@second
