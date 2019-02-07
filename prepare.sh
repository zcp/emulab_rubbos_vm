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
   dst_dir=/tmp
   rm  webapp.zip
   zip -r webapp.zip webapp
   scp webapp.zip $master_host:$dst_dir
   ssh $master_host "cd $dst_dir; sudo rm -r webapp; unzip webapp.zip"

   scp install_kubernetes.sh $master_host:$dst_dir
   scp init_kubernetes.sh $master_host:$dst_dir
   scp emulab-run_rubbos.sh $master_host:$dst_dir
   scp collectl.sh $master_host:$dst_dir
   scp kill_bash.sh $master_host:$dst_dir
   scp git_results.sh $master_host:$dst_dir
   scp lock_stat.sh $master_host:$dst_dir
   scp thread_count.sh $master_host:$dst_dir
   #scp upload_results.sh $master_host:$dst_dir
}

setTimeZone
modify_hosts
update_grub

echo update rubbos config
./update_rubbos_conf.sh
echo rubbos workloads
./generate_rubbos_workload.sh

copyFiles

