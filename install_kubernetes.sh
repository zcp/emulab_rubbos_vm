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
