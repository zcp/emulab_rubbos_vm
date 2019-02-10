#!/bin/bash
host_name=zcp@pc605.emulab.net
master_host=zcp@pc309.emulab.net
client_host=zcp@pc301.emulab.net
httpd_host=zcp@pc296.emulab.net
tomcat_host=zcp@pc300.emulab.net
mysql_host=zcp@pc311.emulab.net

master_ip=155.98.39.109
client_ip=172.20.5.1
httpd_ip=172.20.5.1
tomcat_ip=155.98.39.100
mysql_ip=155.98.39.111

master_hostname=master.zcp-qv46266.infosphere.emulab.net
client_hostname=client.zcp-qv46424.infosphere.emulab.net
httpd_hostname=httpd.zcp-qv46266.infosphere.emulab.net
tomcat_hostname=tomcat.zcp-qv46266.infosphere.emulab.net
mysql_hostname=mysql.zcp-qv46266.infosphere.emulab.net


work_dir=/home/zcp/emulab-vm
dst_dir=/tmp
#copy files to host where httpd vm run.
copyFilesToHttpd(){
    cd $work_dir
    zip webapp.zip -r webapp
    scp *.zip $host_name:$dst_dir
    scp install_httpd.sh  $host_name:$dst_dir
    scp run_install_httpd.sh $host_name:$dst_dir
    scp config_tomcat.sh $host_name:$dst_dir
    scp config_mysql.sh $host_name:$dst_dir
    scp ../rubbos-expanded-dataset.tar.bz2 $host_name:$dst_dir

    ssh $host_name "cd $dst_dir; unzip webapp.zip;"

    #copy files to httpd VM
    ssh $host_name "cd $dst_dir; scp *.zip zcp@$httpd_ip:$dst_dir"
    ssh $host_name "cd $dst_dir; scp install_httpd.sh zcp@$httpd_ip:$dst_dir"
    

    #copy files to mysql VM
    mysql_ip=$httpd_ip
    ssh $host_name "cd $dst_dir/webapp/RUBBoS-Server; scp -r database zcp@$mysql_ip:$dst_dir"
    ssh $host_name "cd $dst_dir; scp rubbos-expanded-dataset.tar.bz2 zcp@$mysql_ip:$dst_dir"
       

}

copyFilesToHttpd
#run httpd install process
#ssh $host_name "cd /tmp; ./run_install_httpd.sh $httpd_ip"
#ssh $host_name "cd /tmp; ./config_tomcat.sh $httpd_ip"
#ssh $host_name "cd /tmp; ./config_mysql.sh $httpd_ip"
