#!/bin/bash
master_host=zcp@pc265.emulab.net
client_host=zcp@pc345.emulab.net
httpd_host=zcp@pc353.emulab.net
tomcat_host=zcp@pc322.emulab.net
mysql_host=zcp@pc278.emulab.net

master_ip=155.98.39.65
client_ip=155.98.39.145
httpd_ip=155.98.39.153
tomcat_ip=155.98.39.122
mysql_ip=155.98.39.78

master_hostname=master.zcp-qv45096.infosphere.emulab.net
httpd_hostname=httpd.zcp-qv45096.infosphere.emulab.net
tomcat_hostname=tomcat.zcp-qv45096.infosphere.emulab.net
mysql_hostname=mysql.zcp-qv45096.infosphere.emulab.net
client_hostname=client.zcp-qv45096.infosphere.emulab.net




ssh $master_host "./init_kubernetes.sh"
#ssh $master_host "sudo kubectl create -f webapp/httpd-service.yaml"
#ssh $master_host "sudo kubectl create -f webapp/tomcat-service.yaml"
#ssh $master_host "sudo kubectl create -f webapp/mysql-service.yaml"

#ssh $master_host "sudo kubectl create -f webapp/httpd-controller.yaml"
#ssh $master_host "sudo kubectl create -f webapp/mysql-controller.yaml"
#ssh $master_host "sudo kubectl create -f webapp/tomcat-controller.yaml"
#ssh $master_host "sudo kubectl create -f webapp/rubbos-client-controller.yaml"

