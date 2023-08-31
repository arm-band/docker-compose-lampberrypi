#!/bin/bash

expect -c '
    set timeout 1;
    spawn sudo mysql_secure_installation;
    expect "Enter current password for root (enter for none): ";
    send -- "\n";
    expect "Switch to unix_socket authentication \[Y/n\] ";
    send -- "n\n";
    expect "Change the root password? \[Y/n\] ";
    send -- "'Y'\n";
    expect "New password: ";
    send -- "'"DB_MARIADB_PASSWORD"'\n";
    expect "Re-enter new password: ";
    send -- "'"DB_MARIADB_PASSWORD"'\n";
    expect "Remove anonymous users? \[Y/n\] ";
    send "Y\n";
    expect "Disallow root login remotely? \[Y/n\] ";
    send "Y\n";
    expect "Remove test database and access to it? \[Y/n\] ";
    send "Y\n";
    expect "Reload privilege tables now? \[Y/n\] ";
    send "Y\n";
    interact;'