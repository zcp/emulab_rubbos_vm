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




modify_hosts(){
   cat hosts_template > hosts
   echo $master_ip $master_hostname >> hosts
   echo $httpd_ip  $httpd_hostname >> hosts
   echo $tomcat_ip $tomcat_hostname >> hosts
   echo $mysql_ip  $mysql_hostname >> hosts
   echo $client_ip $client_hostname >> hosts
}

update_grub(){
   ./update_grub.sh $master_host
   ./update_grub.sh $httpd_host
   ./update_grub.sh $tomcat_host
   ./update_grub.sh $mysql_host
   ./update_grub.sh $client_host
}

setTimeZone(){
   for node in $master_host $client_host $httpd_host $tomcat_host $mysql_host; do
       ssh $node "sudo timedatectl set-timezone America/New_York"
   done
}

copyFiles(){
   scp -r webapp $master_host:/users/zcp
   scp install_kubernetes.sh $master_host:/users/zcp
   scp init_kubernetes.sh $master_host:/users/zcp
   scp emulab-run_rubbos.sh $master_host:/users/zcp
   scp collectl.sh $master_host:/users/zcp
   scp kill_bash.sh $master_host:/users/zcp
}

setTimeZone
modify_hosts
update_grub

echo update rubbos config
./update_rubbos_conf.sh
echo rubbos workloads
./generate_rubbos_workload.sh

copyFiles

