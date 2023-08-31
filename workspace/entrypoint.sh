#!/bin/bash

# gen key & certificate
## localhost
openssl req -new -newkey rsa:2048 -nodes \
        -out /etc/pki/tls/certs/localhost.csr \
        -keyout /etc/pki/tls/private/localhost.key \
        -subj "/C=/ST=/L=/O=/OU=/CN=www.example.com"
openssl x509 -days 365 -req \
        -signkey /etc/pki/tls/private/localhost.key \
        -in /etc/pki/tls/certs/localhost.csr \
        -out /etc/pki/tls/certs/localhost.crt
## .env domain
openssl req -new -newkey rsa:2048 -nodes \
        -out /etc/ssl/private/server.csr \
        -keyout /etc/ssl/private/server.key \
        -subj "/C=/ST=/L=/O=/OU=/CN=*.${2}"
openssl x509 -days 365 -req \
        -signkey /etc/ssl/private/server.key \
        -in /etc/ssl/private/server.csr \
        -out /etc/ssl/private/server.crt

# setting file replace and copy
sed -e "s/WEB_ROOT_DIRECTORY/${1}/gi" \
    -e "s/WEB_DOMAIN/${2}/gi" \
    -e "s/WEB_HOST_PORTNUM/${3}/gi" \
    -e "s/WEB_CONTAINER_PORTNUM/${4}/gi" \
    -e "s/WEB_HOST_PORTSSL/${5}/gi" \
    -e "s/WEB_CONTAINER_PORTSSL/${6}/gi" \
        /template/apache/apache_vh.conf > /etc/apache2/sites-available/${1}.conf
sed -e "s/WEB_ROOT_DIRECTORY/${1}/gi" \
    -e "s/WEB_DOMAIN/${2}/gi" \
    -e "s/WEB_HOST_PORTNUM/${3}/gi" \
    -e "s/WEB_CONTAINER_PORTNUM/${4}/gi" \
    -e "s/WEB_HOST_PORTSSL/${5}/gi" \
    -e "s/WEB_CONTAINER_PORTSSL/${6}/gi" \
        /template/apache/apache_vh_ssl.conf > /etc/apache2/sites-available/${1}_ssl.conf
## # apache log
## echo 'CustomLog "|/usr/bin/logger -p local5.info -t httpd_access" combined' >> /etc/apache2/apache2.conf
## sed -ri 's/^ErrorLog ${APACHE_LOG_DIR}\/error.log/ErrorLog "|\/usr\/bin\/logger -p local6.info -t error"/' /etc/apache2/apache2.conf
## # rsyslog
## cat <<EOL >> /etc/rsyslog.d/50-default.conf
## *.info;mail.none;authpriv.none;cron.none;local5.none;local6.none;                /var/log/messages
##
## # apache2 access log
## local5.*                                              @nekoishi
## local5.*                                              /var/log/apache2/access.log
## # apache2 error log
## local6.*                                              @nekoishi
## local6.*                                              /var/log/apache2/error.log
##
## EOL

cp /template/apache/ssl.conf /etc/apache2/mods-available/ssl.conf

# permission
chown -R apache:apache /var/www/${1}/web
find /var/www/${1}/web/ -type f -exec chmod 666 {} \;
find /var/www/${1}/web/ -type d -exec chmod 777 {} \;

# apache module enable
a2enmod ssl proxy_fcgi setenvif rewrite
# apache conf enable
echo ServerName www.example.com:${4} >> /etc/apache2/conf-available/example.conf
a2enconf example php${9}-fpm
# apache cirtual site enable
a2ensite ${1} ${1}_ssl
# apache service start
service apache2 start

# PHP
/usr/sbin/php-fpm${9} &

# SSH
sed -ri 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
echo "${7}:${8}" | /usr/sbin/chpasswd
ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_rsa_key <<< y
/usr/sbin/sshd -D &

## # rsyslog
## /usr/sbin/rsyslogd -D &

# MariaDB
SOCKFILE="/run/mysqld/mysqld.sock"

sed -e "s/DB_CONTAINER_PORTNUM/${10}/gi" /template/mariadb/conf.d/mysql.cnf > /etc/mysql/conf.d/mysql.cnf
cp /template/mariadb/mariadb.conf.d/20-default-authentication-plugin.cnf /etc/mysql/mariadb.conf.d/20-default-authentication-plugin.cnf
cp /template/mariadb/mariadb.conf.d/40-pass.cnf /etc/mysql/mariadb.conf.d/40-pass.cnf
cp /template/mariadb/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# setting file replace and copy (for phpMyAdmin)
sed -e "s/PHPMYADMIN_ROOT_DIRECTORY/${12}/gi" \
    -e "s/WEB_DOMAIN/${2}/gi" \
    -e "s/PHPMYADMIN_CONTAINER_PORTNUM/${13}/gi" \
        /template/phpmyadmin/phpmyadmin_vh.conf > /etc/apache2/sites-available/${12}.conf
RANDHEXVAL=`openssl rand -hex 32`
sed -e "s/\$cfg\['blowfish_secret'\] = '';/\$cfg\['blowfish_secret'\] = '${RANDHEXVAL}';/gi" \
        /var/www/${12}/web/config.sample.inc.php > /var/www/${12}/web/config.inc.php

# permission
chown -R apache:apache /var/www/${12}/web

# apache cirtual site enable
a2ensite ${12}
# phpMyAdmin Port
echo Listen ${13} >> /etc/apache2/ports.conf
# apache service start
service apache2 reload

# MariaDB initialize
# MariaDB doesn't have --initialize option.
## /usr/sbin/mysqld --user=mysql --initialize &
/usr/sbin/mysqld --user=mysql &
echo "mysqld initialized"
sed -e "s/DB_MARIADB_PASSWORD/${11}/gi" \
        /template/mariadb/mysql_secure_installation_script.sh > /workspace/mysql_secure_installation_script.sh
/workspace/mysql_secure_installation_script.sh &
# scripting "mysql_secure_installation" interactive mode
# expect -c '
#     set timeout 1;
#     spawn sudo mysql_secure_installation;
#     expect "Enter current password for root (enter for none): ";
#     send -- "\n";
#     expect "Switch to unix_socket authentication \[Y/n\] ";
#     send -- "n\n";
#     expect "Change the root password? \[Y/n\] ";
#     send -- "'Y'\n";
#     expect "New password: ";
#     send -- "'"${11}"'\n";
#     expect "Re-enter new password: ";
#     send -- "'"${11}"'\n";
#     expect "Remove anonymous users? \[Y/n\] ";
#     send "Y\n";
#     expect "Disallow root login remotely? \[Y/n\] ";
#     send "Y\n";
#     expect "Remove test database and access to it? \[Y/n\] ";
#     send "Y\n";
#     expect "Reload privilege tables now? \[Y/n\] ";
#     send "Y\n";
#     interact;'
# # change root password (Because the authentication_string column is invalid and root cannot log in with phpMyAdmin)
# sudo mysql -u root -p${11} --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${11}'; FLUSH PRIVILEGES;"
# #    # change root password and add phpMyAdmin user
# #    sudo mysql -u root -p${11} --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${11}'; CREATE USER '${14}'@'%' IDENTIFIED BY '${15}'; GRANT ALL ON *.* TO '${14}'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;"
echo "mysqld boot"