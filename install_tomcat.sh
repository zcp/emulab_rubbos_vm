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



setLabels(){
   #kubectl create -f /home/zcp/docker_applications/kube/staging/spark/namespace-spark-cluster.yaml
   kubectl label nodes $master_hostname diskspeed=master
   sleep 30s
   kubectl label nodes $httpd_hostname diskspeed=httpd
   sleep 30s
   kubectl label nodes $tomcat_hostname diskspeed=tomcat
   sleep 30s
   kubectl label nodes $mysql_hostname diskspeed=mysql
   sleep 30s
   kubectl label nodes $client_hostname diskspeed=client
}

activateDocker(){
   for node in $master_host $client_host $httpd_host $tomcat_host $mysql_host; do
       ssh $node "sudo groupadd docker"
       ssh $node "sudo systemctl start docker.service"
       ssh $node "sudo systemctl enable docker.service"
   done
}

activateMaster(){
    sudo swapoff -a
    rm -rf /var/lib/cni/flannel/* && rm -rf /var/lib/cni/networks/cbr0/* && ip link delete cni0  
    rm -rf /var/lib/cni/networks/cni0/*
    sudo kubeadm reset
    sudo systemctl restart kubelet

    sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$master_ip
    sudo mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    export kubever=$(kubectl version | base64 | tr -d '\n')
    sudo kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"
    #sudo kubectl create -f kube-flannel_eth0.yml 
}

addNodes(){
     join_token=$(kubeadm token create --print-join-command)
     for node in $client_host $httpd_host $tomcat_host $mysql_host; do
         ssh $node "rm -rf /var/lib/cni/flannel/* && rm -rf /var/lib/cni/networks/cbr0/* && ip link delete cni0"
         ssh $node "rm -rf /var/lib/cni/networks/cni0/*"
         ssh $node  "sudo kubeadm reset; sudo swapoff -a; sudo $join_token"
     done
}

activateDocker
activateMaster
addNodes
setLabels
