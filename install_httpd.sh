#!/bin/bash
#run on httpd vm

apr_name=apr-1.6.5
apr_util_name=apr-util-1.6.1
httpd_name=elba-httpd-2.4.37
httpd_conf=elba-httpd-2.4-conf
mod_jk=elba-tomcat-connectors-1.2.46-src

install_httpd(){
   cd /tmp
   unzip $apr_name.zip
   unzip $apr_util_name.zip
   unzip $httpd_name.zip
   unzip $httpd_conf.zip
   unzip $mod_jk.zip

   sudo apt-get update
   yes Y | sudo apt-get install gcc
   yes Y | sudo apt-get install make
   yes Y | sudo apt-get install libpcre3-dev
   yes Y | sudo apt-get install libexpat1-dev
   yes Y | sudo apt-get install libpcre3-dev
   yes Y | sudo apt-get install libtool
   yes Y | sudo apt-get install openjdk-8-jdk
   
   #shutdown apache2 in ubuntu 16.04LTS
   sudo systemctl stop apache2

   #install apr
   cd /tmp/$apr_name
   ./configure --prefix=/usr/local/apr-httpd/
   sudo make
   sudo make install

   #install apr-util
   cd  /tmp/$apr_util_name
   ./configure --prefix=/usr/local/apr-util-httpd/ --with-apr=/usr/local/apr-httpd/
   sudo make
   sudo make install

   # Configure httpd
   #all modifications are in elba-httpd-2.4.37
   #install elba-httpd-2.4.37
   cd /tmp/$httpd_name
   ./configure --prefix=/usr/local/apache2 --with-apr=/usr/local/apr-httpd/ --with-apr-util=/usr/local/apr-util-httpd/
   sudo make
   sudo make install

   #install mod_jk
   cd /tmp/$mod_jk/native
   ./configure --with-apxs=/usr/local/apache2/bin/apxs 
   sudo make
   sudo cp apache-2.0/mod_jk.so /usr/local/apache2/modules/

   sudo cp -r /tmp/elba-httpd-2.4-conf/* /usr/local/apache2/conf
   cd /usr/local/apache2/bin
   sudo ./apachectl start
   #sudo systemctl restart httpd 
}

install_httpd

