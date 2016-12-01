FROM ubuntu:16.04

RUN apt-get update && apt-get install wget -y
RUN wget http://repo.zabbix.com/zabbix/3.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_3.2-1+xenial_all.deb 
RUN dpkg -i zabbix-release_3.2-1+xenial_all.deb
RUN apt-get update
RUN echo "mysql-server mysql-server/root_password password Bolinha123" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password Bolinha123" | debconf-set-selections
RUN apt-get -y install mysql-server
RUN apt-get install zabbix-server-mysql zabbix-frontend-php zabbix-agent zabbix-get -y
RUN apt-get install php-xmlwriter php-xmlreader php-mbstring php-bcmath -y
RUN sed -i 's/# php_value date.timezone Europe\/Riga/php_value date.timezone America\/Sao_Paulo/' /etc/zabbix/apache.conf
RUN sed -i 's/# DBHost=localhost/DBHost=localhost/' /etc/zabbix/zabbix_server.conf
RUN sed -i 's/# DBPassword=/DBPassword=zabbix/'  /etc/zabbix/zabbix_server.conf
RUN sed -i 's/# ListenPort=10051/ListenPort=10051/' /etc/zabbix/zabbix_server.conf
RUN sed -i 's/# EnableRemoteCommands=0/EnableRemoteCommands=1/' /etc/zabbix/zabbix_agentd.conf
RUN sed -i 's/# LogRemoteCommands=0/LogRemoteCommands=1/' /etc/zabbix/zabbix_agentd.conf
RUN sed -i 's/Hostname=Zabbix server/# Hostname=Zabbix server/' /etc/zabbix/zabbix_agentd.conf
RUN sed -i 's/# HostnameItem=system.hostname/HostnameItem=system.hostname/' /etc/zabbix/zabbix_agentd.conf
RUN sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/usr\/share\/zabbix/' /etc/apache2/sites-available/000-default.conf
RUN echo '#!/bin/bash' > zabbix_start.sh
RUN echo "if [ ! -f /var/lib/mysql/zabbix/items.frm ]; then " >> zabbix_start.sh
RUN echo "cp -Rf /var/lib/mysqlb/* /var/lib/mysql" >> zabbix_start.sh
RUN echo "/usr/sbin/service mysql start" >> zabbix_start.sh
RUN echo "mysql -uroot -pBolinha123 -e 'create database zabbix character set utf8 collate utf8_bin' " >> zabbix_start.sh
RUN echo "zcat  /usr/share/doc/zabbix-server-mysql/create.sql.gz | mysql -uroot -pBolinha123 -B zabbix" >> zabbix_start.sh 
RUN echo "fi;" >> zabbix_start.sh
RUN echo "/usr/sbin/service mysql start" >> zabbix_start.sh
RUN echo "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix'" >> b.txt
RUN echo 'mysql -uroot -pBolinha123 < b.txt' >> zabbix_start.sh
RUN echo "/usr/sbin/service apache2 start" >> zabbix_start.sh
RUN echo "/usr/sbin/service zabbix-server start" >> zabbix_start.sh
RUN echo "/usr/sbin/service zabbix-agent start" >> zabbix_start.sh
RUN echo "c=1" >> zabbix_start.sh
RUN echo "while [ \$c -le 5 ]" >> zabbix_start.sh
RUN echo "do" >> zabbix_start.sh
RUN echo "echo 'ok';" >> zabbix_start.sh
RUN echo "sleep 5000" >> zabbix_start.sh
RUN echo "done" >> zabbix_start.sh
RUN chmod +x  zabbix_start.sh
RUN apt-get -y install snmp snmpd
RUN sed -i 's/mibs :/mibs +/' /etc/snmp/snmp.conf
RUN echo "deb http://ftp.br.debian.org/debian/ wheezy main contrib non-free" >> /etc/apt/sources.list
RUN echo "deb-src http://ftp.br.debian.org/debian/ wheezy main contrib non-free" >>/etc/apt/sources.list
RUN apt-get update && apt-get install snmp-mibs-downloader  --allow-unauthenticated -y
RUN echo "<?php" >/usr/share/zabbix/conf/zabbix.conf.php
RUN echo "// Zabbix GUI configuration file." >> /usr/share/zabbix/conf/zabbix.conf.php
RUN echo "global \$DB; " >> /usr/share/zabbix/conf/zabbix.conf.php
RUN echo "\$DB['TYPE']     = 'MYSQL'; " >> /usr/share/zabbix/conf/zabbix.conf.php
RUN echo "\$DB['SERVER']   = 'localhost'; " >> /usr/share/zabbix/conf/zabbix.conf.php
RUN echo "\$DB['PORT']     = '0'; " >> /usr/share/zabbix/conf/zabbix.conf.php
RUN echo "\$DB['DATABASE'] = 'zabbix';" >> /usr/share/zabbix/conf/zabbix.conf.php
RUN echo "\$DB['USER']     = 'zabbix';" >> /usr/share/zabbix/conf/zabbix.conf.php
RUN echo "\$DB['PASSWORD'] = 'zabbix';" >> /usr/share/zabbix/conf/zabbix.conf.php
RUN echo "// Schema name. Used for IBM DB2 and PostgreSQL." >> /usr/share/zabbix/conf/zabbix.conf.php
RUN echo "\$DB['SCHEMA'] = '';" >> /usr/share/zabbix/conf/zabbix.conf.php
RUN echo "\$ZBX_SERVER      = 'localhost';" >> /usr/share/zabbix/conf/zabbix.conf.php
RUN echo "\$ZBX_SERVER_PORT = '10051';" >> /usr/share/zabbix/conf/zabbix.conf.php
RUN echo "\$ZBX_SERVER_NAME = 'zabbix';" >> /usr/share/zabbix/conf/zabbix.conf.php
RUN echo "\$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;" >> /usr/share/zabbix/conf/zabbix.conf.php
RUN cp -R /var/lib/mysql    /var/lib/mysqlb
RUN apt-get autoclean




CMD ./zabbix_start.sh
