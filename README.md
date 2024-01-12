## Цель домашнего задания
#### Выполнить следующие задания и подготовить развёртывание результата выполнения с использованием Vagrant и Vagrant shell provisioner (или Ansible, на Ваше усмотрение):

    1. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig или в /etc/default).
    2. Установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi).
    3. Дополнить unit-файл httpd (он же apache2) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами.


## Решение

Подготовлен Vagrant файл и скрипт. Разворачивается система с выполненными пунктами задания.
Проверка:

1. [root@RPM ~]# tail -f /var/log/messages
Jan 12 13:43:14 centos8s systemd[1]: Started User Manager for UID 1000.
Jan 12 13:43:14 centos8s systemd[1]: Started Session 4 of user vagrant.
Jan 12 13:44:44 centos8s chronyd[805]: Selected source 167.86.91.16 (2.centos.pool.ntp.org)
Jan 12 13:45:59 centos8s systemd[5970]: Starting Mark boot as successful...
Jan 12 13:45:59 centos8s systemd[5970]: Started Mark boot as successful.
Jan 12 13:47:37 centos8s systemd-udevd[670]: Network interface NamePolicy= disabled on kernel command line, ignoring.
Jan 12 13:49:23 centos8s systemd[1]: Starting My watchlog service...
Jan 12 13:49:23 centos8s root[6063]: Fri Jan 12 13:49:23 UTC 2024: I found word, Master!
Jan 12 13:49:23 centos8s systemd[1]: watchlog.service: Succeeded.
Jan 12 13:49:23 centos8s systemd[1]: Started My watchlog service.


2. [root@RPM ~]# systemctl status spawn-fcgi
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
   Active: active (running) since Fri 2024-01-12 13:42:40 UTC; 4min 14s ago
 Main PID: 5476 (php-cgi)
    Tasks: 33 (limit: 23220)
   Memory: 19.0M
   CGroup: /system.slice/spawn-fcgi.service
           ├─5476 /usr/bin/php-cgi
           ├─5480 /usr/bin/php-cgi
           ├─5481 /usr/bin/php-cgi
           ├─5482 /usr/bin/php-cgi
           ├─5483 /usr/bin/php-cgi
           ├─5484 /usr/bin/php-cgi
           ├─5485 /usr/bin/php-cgi
           ├─5486 /usr/bin/php-cgi
           ├─5487 /usr/bin/php-cgi
           ├─5488 /usr/bin/php-cgi
           ├─5489 /usr/bin/php-cgi
           ├─5490 /usr/bin/php-cgi
           ├─5491 /usr/bin/php-cgi
           ├─5492 /usr/bin/php-cgi
           ├─5493 /usr/bin/php-cgi
           ├─5494 /usr/bin/php-cgi

3. [root@RPM ~]# ss -tnulp | grep httpd
tcp   LISTEN 0      511                *:8080            *:*    users:(("httpd",pid=5745,fd=4),("httpd",pid=5744,fd=4),("httpd",pid=5743,fd=4),("httpd",pid=5742,fd=4),("httpd",pid=5740,fd=4))
tcp   LISTEN 0      511                *:80              *:*    users:(("httpd",pid=5524,fd=4),("httpd",pid=5523,fd=4),("httpd",pid=5522,fd=4),("httpd",pid=5521,fd=4),("httpd",pid=5516,fd=4))
