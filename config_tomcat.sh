#!/bin/bash
#the script runs on a physic host
tomcat_ip=$1

log4j_properties=/var/lib/tomcat8/webapps/rubbos/WEB-INF/classes/log4j.properties

ssh zcp@$tomcat_ip "sudo apt-get update"
ssh zcp@$tomcat_ip "yes Y | sudo apt-get install tomcat8"

cd /tmp/
yes Y | unzip webapp.zip
cd /tmp/webapp/RUBBoS-Server/
ssh zcp@$tomcat_ip "mkdir -p /tmp/RUBBoS"
scp mysql.properties zcp@$tomcat_ip:/tmp/RUBBos
scp -r Servlet_HTML zcp@$tomcat_ip:/tmp/RUBBos

#deploy rubbos in tomcat
cd /tmp/webapp/RUBBoS-Server/webapps
scp -r rubbos zcp@$tomcat_ip:/tmp
ssh zcp@$tomcat_ip "cd /tmp; sudo cp -r rubbos /var/lib/tomcat8/webapps"
#modify variables.
ssh zcp@$tomcat_ip "sudo sed -i 's/^log4j.appender.file.File.*/log4j.appender.file.File=\/var\/log\/tomcat8\/rubbos-servlets.log/' $log4j_properties"


ssh zcp@$tomcat_ip "sudo systemctl restart tomcat8"

