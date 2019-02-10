#!/bin/bash
#the script runs on a physical host
mysql_ip=$1

mysql_conf=/etc/mysql/mysql.conf.d/mysqld.cnf

ssh zcp@$mysql_ip "sudo apt-get update"

ssh zcp@$mysql_ip "sudo debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password password your_password'"

ssh zcp@$mysql_ip "sudo debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password_again password your_password'"

ssh zcp@$mysql_ip "yes Y |sudo apt-get -y install mysql-server-5.7"

ssh zcp@$mysql_ip "sudo sed -i '/^bind-address.*/a skip-grant-tables' $mysql_conf"
ssh zcp@$mysql_ip "sudo sed -i 's/^bind-address.*/#bind_address=/' $mysql_conf"
ssh zcp@$mysql_ip "sudo systemctl restart mysql"


#scp -r /tmp/database zcp@$mysql_ip:/tmp

ssh zcp@$mysql_ip "cd /tmp; tar -xjvf rubbos-expanded-dataset.tar.bz2 -C /tmp/database"
ssh zcp@$mysql_ip "cd /tmp/database/rubbos-expanded-dataset; mv *.data ../"
ssh zcp@$mysql_ip "cd /tmp/database; mysql -u root --password=123456 < rubbos.sql"
ssh zcp@$mysql_ip "cd /tmp/database; mysql -u root --password=123456 < load.sql"



