FROM raspios-bullseye-armhf64-lite:2023-05-03
# args
ARG WEB_ROOT_DIRECTORY
ARG PHPMYADMIN_ROOT_DIRECTORY
ARG PHPMYADMIN_VERSION
# install tzdata without interactive
ENV DEBIAN_FRONTEND=noninteractive
# apt update & install
RUN apt update \
 && apt upgrade -y \
 && apt install -y sudo \
                   vim \
                   less \
                   procps \
                   # network ss (instaed of netstat)
                   iproute2 \
                   # apache
                   apache2 \
                   # zip
                   zip \
                   unzip \
                   # SSL
                   openssl \
                   # SSH
                   openssh-server \
                   # git
                   git \
                   # expect
                   expect \
                   # syslog
                   rsyslog \
                   # cleaning
                && apt clean \
                && rm -rf /var/lib/apt/lists/*
# install php
RUN wget -qO /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
 && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list \
 && apt update \
 && apt upgrade -y \
 && apt install -y php \
                libapache2-mod-php \
                php-fpm \
                php-common \
                php-mbstring \
                php-xmlrpc \
                php-gd \
                php-xml \
                php-cli \
                php-zip \
                php-curl \
                php-imagick \
                # MySQL
                php-mysql \
                # Xdebug
                php-xdebug \
                # cleaning
                && apt clean \
                && rm -rf /var/lib/apt/lists/*
# composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
 && php composer-setup.php \
 && php -r "unlink('composer-setup.php');" \
 && mv composer.phar /usr/local/bin/composer
# PHP
RUN mkdir -p /run/php
RUN chown www-data:www-data /run/php
# php log
RUN mkdir /var/log/php
RUN chown www-data /var/log/php
RUN chmod 755 /var/log/php
# SSL
RUN mkdir -p /etc/ssl/private
# volume directory
RUN mkdir -p /template
RUN mkdir -p /var/www/${WEB_ROOT_DIRECTORY}
RUN mkdir -p /var/www/${WEB_ROOT_DIRECTORY}/web
RUN mkdir -p /workspace
# SSH
RUN mkdir -p /var/run/sshd
# MariaDB
RUN apt update \
 && apt upgrade -y \
 && apt install -y mariadb-server mariadb-client \
 && chown -R mysql:mysql /var/log/mysql \
 && chown -R mysql:mysql /var/lib/mysql/ \
 && mkdir /run/mysqld/ \
 && chown -R mysql:mysql /run/mysqld/
# phpMyAdmin volume directory
RUN mkdir -p /var/www/${PHPMYADMIN_ROOT_DIRECTORY}
RUN mkdir -p /var/www/${PHPMYADMIN_ROOT_DIRECTORY}/web
WORKDIR /var/www/${PHPMYADMIN_ROOT_DIRECTORY}/
RUN wget https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz \
 && tar xvzf phpMyAdmin-*.tar.gz \
 && mv phpMyAdmin-*all-languages/* /var/www/${PHPMYADMIN_ROOT_DIRECTORY}/web/