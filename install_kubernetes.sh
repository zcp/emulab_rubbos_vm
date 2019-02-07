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





install_kube(){
   
   sudo apt-get update && apt-get install -y apt-transport-https
   echo "y" | sudo apt-get install docker.io
   sudo systemctl stop ufw && sudo systemctl disable ufw
   sudo systemctl start docker && sudo systemctl enable docker
   sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add 
   sudo echo deb http://apt.kubernetes.io/ kubernetes-xenial main >  /etc/apt/sources.list.d/kubernetes.list
   sudo apt-get update
   sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni
   sudo systemctl restart kubelet && sudo systemctl enable kubelet
   sudo swapoff -a

#   sudo apt-get install collectl -y
}

install_kube
