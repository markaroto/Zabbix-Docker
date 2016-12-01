FROM ubuntu:16.04
MAINTAINER  Marcos Flavio marcos_flavio@live.com

#Instalando repositorio
RUN apt-get update && apt-get install wget -y && \
	wget http://repo.zabbix.com/zabbix/3.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_3.2-1+xenial_all.deb && \
	dpkg -i zabbix-release_3.2-1+xenial_all.deb && \
	apt-get update

#Install mysql
RUN echo "mysql-server mysql-server/root_password password Bolinha123" | debconf-set-selections && \
	echo "mysql-server mysql-server/root_password_again password Bolinha123" | debconf-set-selections && \
	apt-get -y install mysql-server
#Install  zabbix
RUN apt-get install zabbix-server-mysql zabbix-frontend-php zabbix-agent zabbix-get -y && \
	apt-get install php-xmlwriter php-xmlreader php-mbstring php-bcmath -y && \
	sed -i 's/# php_value date.timezone Europe\/Riga/php_value date.timezone America\/Sao_Paulo/' /etc/zabbix/apache.conf && \
	sed -i 's/# DBHost=localhost/DBHost=localhost/' /etc/zabbix/zabbix_server.conf && \
	sed -i 's/# DBPassword=/DBPassword=zabbix/'  /etc/zabbix/zabbix_server.conf && \
	sed -i 's/# ListenPort=10051/ListenPort=10051/' /etc/zabbix/zabbix_server.conf && \
	sed -i 's/# EnableRemoteCommands=0/EnableRemoteCommands=1/' /etc/zabbix/zabbix_agentd.conf && \
	sed -i 's/# LogRemoteCommands=0/LogRemoteCommands=1/' /etc/zabbix/zabbix_agentd.conf && \
	sed -i 's/Hostname=Zabbix server/# Hostname=Zabbix server/' /etc/zabbix/zabbix_agentd.conf && \
	sed -i 's/# HostnameItem=system.hostname/HostnameItem=system.hostname/' /etc/zabbix/zabbix_agentd.conf && \
	sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/usr\/share\/zabbix/' /etc/apache2/sites-available/000-default.conf
#script zabbix_start.sh
RUN echo '#!/bin/bash' > zabbix_start.sh && \
	echo "if [ ! -f /var/lib/mysql/zabbix/items.frm ]; then " >> zabbix_start.sh && \
	echo "cp -Rf /var/lib/mysqlb/* /var/lib/mysql" >> zabbix_start.sh && \
	echo "/usr/sbin/service mysql start" >> zabbix_start.sh && \
	echo "mysql -uroot -pBolinha123 -e 'create database zabbix character set utf8 collate utf8_bin' " >> zabbix_start.sh && \
	echo "zcat  /usr/share/doc/zabbix-server-mysql/create.sql.gz | mysql -uroot -pBolinha123 -B zabbix" >> zabbix_start.sh && \
	echo "fi;" >> zabbix_start.sh && \
	echo "/usr/sbin/service mysql start" >> zabbix_start.sh && \
	echo "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix'" >> b.txt && \
	echo 'mysql -uroot -pBolinha123 < b.txt' >> zabbix_start.sh && \
	echo "/usr/sbin/service apache2 start" >> zabbix_start.sh && \
	echo "/usr/sbin/service zabbix-server start" >> zabbix_start.sh && \
	echo "/usr/sbin/service zabbix-agent start" >> zabbix_start.sh && \
	echo "c=1" >> zabbix_start.sh && \
	echo "while [ \$c -le 5 ]" >> zabbix_start.sh && \
	echo "do" >> zabbix_start.sh && \
	echo "echo 'ok';" >> zabbix_start.sh && \
	echo "sleep 5000" >> zabbix_start.sh && \
	echo "done" >> zabbix_start.sh && \
	chmod +x  zabbix_start.sh 

#install snmp configuration	
RUN	apt-get -y install snmp snmpd && \
	sed -i 's/mibs :/mibs +/' /etc/snmp/snmp.conf && \
	echo "deb http://ftp.br.debian.org/debian/ wheezy main contrib non-free" >> /etc/apt/sources.list && \
	echo "deb-src http://ftp.br.debian.org/debian/ wheezy main contrib non-free" >>/etc/apt/sources.list && \
	apt-get update && apt-get install snmp-mibs-downloader  --allow-unauthenticated -y
#Zabbix.config
RUN echo "<?php" >/usr/share/zabbix/conf/zabbix.conf.php && \
	echo "// Zabbix GUI configuration file." >> /usr/share/zabbix/conf/zabbix.conf.php && \
	echo "global \$DB; " >> /usr/share/zabbix/conf/zabbix.conf.php && \
	echo "\$DB['TYPE']     = 'MYSQL'; " >> /usr/share/zabbix/conf/zabbix.conf.php && \
	echo "\$DB['SERVER']   = 'localhost'; " >> /usr/share/zabbix/conf/zabbix.conf.php && \
	echo "\$DB['PORT']     = '0'; " >> /usr/share/zabbix/conf/zabbix.conf.php && \
	echo "\$DB['DATABASE'] = 'zabbix';" >> /usr/share/zabbix/conf/zabbix.conf.php && \
	echo "\$DB['USER']     = 'zabbix';" >> /usr/share/zabbix/conf/zabbix.conf.php && \
	echo "\$DB['PASSWORD'] = 'zabbix';" >> /usr/share/zabbix/conf/zabbix.conf.php && \
	echo "// Schema name. Used for IBM DB2 and PostgreSQL." >> /usr/share/zabbix/conf/zabbix.conf.php && \
	echo "\$DB['SCHEMA'] = '';" >> /usr/share/zabbix/conf/zabbix.conf.php && \
	echo "\$ZBX_SERVER      = 'localhost';" >> /usr/share/zabbix/conf/zabbix.conf.php && \
	echo "\$ZBX_SERVER_PORT = '10051';" >> /usr/share/zabbix/conf/zabbix.conf.php && \
	echo "\$ZBX_SERVER_NAME = 'zabbix';" >> /usr/share/zabbix/conf/zabbix.conf.php && \
	echo "\$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;" >> /usr/share/zabbix/conf/zabbix.conf.php
#Copy of database
RUN cp -R /var/lib/mysql    /var/lib/mysqlb





CMD ./zabbix_start.sh
