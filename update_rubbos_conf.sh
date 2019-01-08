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




#update mysql.properties of rubbos server
#mysql_host=xxx.xxx.xxx.xxx
rubbos_server_conf=/home/zcp/emulab/webapp/RUBBoS-Server/mysql.properties
sed -i "s/^datasource.url.*/datasource.url   jdbc:mysql:\/\/$mysql_ip:31101\/rubbos/" $rubbos_server_conf

#update worker.properties of httpd
#tomcat_host=$mysql_host
workers_properties_path=/home/zcp/emulab/webapp/elba-httpd-2.4-conf/workers.properties
sed -i "s/^worker.worker1.host.*/worker.worker1.host=$tomcat_ip/" $workers_properties_path



#update rubbos.properties of client
#httpd_host=$mysql_host

rubbos_properties_path=/home/zcp/emulab/webapp/RUBBoS-Client/Client/rubbos.properties
sed -i "s/^httpd_hostname.*/httpd_hostname=$httpd_ip/" $rubbos_properties_path
sed -i "s/^servlets_server.*/servlets_server=$httpd_ip/" $rubbos_properties_path
sed -i "s/^database_master_server.*/database_master_server=$mysql_ip/" $rubbos_properties_path
sed -i "s/^database_slave_server.*/database_slave_servers=$mysql_ip/" $rubbos_properties_path
sed -i "s/^workload_remote_client_nodes.*/workload_remote_client_nodes=$client_ip/" $rubbos_properties_path

