#!/bin/bash
master_host=zcp@pc309.emulab.net
client_host=zcp@pc301.emulab.net
httpd_host=zcp@pc296.emulab.net
tomcat_host=zcp@pc300.emulab.net
mysql_host=zcp@pc311.emulab.net

master_ip=155.98.39.109
client_ip=155.98.39.101
httpd_ip=155.98.39.96
tomcat_ip=155.98.39.100
mysql_ip=155.98.39.111

master_hostname=master.zcp-qv46266.infosphere.emulab.net
client_hostname=client.zcp-qv46266.infosphere.emulab.net
httpd_hostname=httpd.zcp-qv46266.infosphere.emulab.net
tomcat_hostname=tomcat.zcp-qv46266.infosphere.emulab.net
mysql_hostname=mysql.zcp-qv46266.infosphere.emulab.net





ssh $master_host "./init_kubernetes.sh"
#ssh $master_host "sudo kubectl create -f webapp/httpd-service.yaml"
#ssh $master_host "sudo kubectl create -f webapp/tomcat-service.yaml"
#ssh $master_host "sudo kubectl create -f webapp/mysql-service.yaml"

#ssh $master_host "sudo kubectl create -f webapp/httpd-controller.yaml"
#ssh $master_host "sudo kubectl create -f webapp/mysql-controller.yaml"
#ssh $master_host "sudo kubectl create -f webapp/tomcat-controller.yaml"
#ssh $master_host "sudo kubectl create -f webapp/rubbos-client-controller.yaml"

