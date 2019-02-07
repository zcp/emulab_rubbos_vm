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







execution_dir=/tmp/RUBBoS
rubbos_client_dir=RUBBoS-Client-current
cur_dir=/tmp/webapp
monitor_dir=/tmp/monitor

run_script=run_rubbos_client.sh
monitor_script=collectl.sh
kill_script=kill_bash.sh
lock_script=lock_stat.sh
thread_count_script=thread_count.sh

lock_log=/dev/shm/lock_stats.txt
thread_count_log=/dev/shm/thread_count.txt
collectl_cpu=$monitor_dir/cpu.txt
collectl_disk=$monitor_dir/disk.txt
collectl_mem=$monitor_dir/mem.txt
collectl_net=$monitor_dir/net.txt

start_monitor(){
    #ssh $master_host  "sudo $monitor_dir/$lock_script $lock_log" &  
    #ssh $master_host  "sudo $monitor_dir/$thread_count_script $thread_count_log" &  
    ssh $master_host   "sudo $monitor_dir/$monitor_script $collectl_cpu $collectl_mem $collectl_disk $collectl_net" &

    #ssh $httpd_host   "sudo $monitor_dir/$lock_script $lock_log" &  
    ssh $httpd_host    "sudo $monitor_dir/$thread_count_script k8s_httpd $thread_count_log" &  
    ssh $httpd_host    "sudo $monitor_dir/$monitor_script $collectl_cpu $collectl_mem $collectl_disk $collectl_net" &

    #ssh $tomcat_host  "sudo $monitor_dir/$lock_script $lock_log"& 
    ssh $tomcat_host   "sudo $monitor_dir/$thread_count_script k8s_tomcat $thread_count_log" &  
    ssh $tomcat_host   "sudo $monitor_dir/$monitor_script $collectl_cpu $collectl_mem $collectl_disk $collectl_net" &
    
    #ssh $mysql_host   "sudo $monitor_dir/$lock_script $lock_log" &
    ssh $mysql_host    "sudo $monitor_dir/$thread_count_script k8s_mysql $thread_count_log" &  
    ssh $mysql_host    "sudo $monitor_dir/$monitor_script $collectl_cpu $collectl_mem $collectl_disk $collectl_net" &
}

clean_monitor(){
    ssh $master_host "sudo $monitor_dir/$kill_script collectl"
    #ssh $master_host "sudo $monitor_dir/$kill_script lock_stat.sh"
    #ssh $master_host "sudo $monitor_dir/$kill_script thread_count.sh"

    ssh $httpd_host "sudo $monitor_dir/$kill_script collectl"
    #ssh $httpd_host "sudo $monitor_dir/$kill_script lock_stat.sh"
    ssh $httpd_host "sudo $monitor_dir/$kill_script thread_count.sh"

    ssh $tomcat_host "sudo $monitor_dir/$kill_script collectl"
    #ssh $tomcat_host "sudo $monitor_dir/$kill_script lock_stat.sh"
    ssh $tomcat_host "sudo $monitor_dir/$kill_script thread_count.sh"

    ssh $mysql_host "sudo $monitor_dir/$kill_script collectl"   
    #ssh $mysql_host "sudo $monitor_dir/$kill_script lock_stat.sh"   
    ssh $mysql_host "sudo $monitor_dir/$kill_script thread_count.sh"
}

copyFiles(){
   mkdir -p $monitor_dir
   ssh $httpd_host "mkdir -p $monitor_dir"
   ssh $tomcat_host "mkdir -p $monitor_dir"
   ssh $mysql_host "mkdir -p $monitor_dir"   
  
   cd  $cur_dir; cd ..;
   cp  $monitor_script $kill_script $lock_script $thread_count_script $monitor_dir
   scp $monitor_script $kill_script $lock_script $thread_count_script $httpd_host:$monitor_dir
   scp $monitor_script $kill_script $lock_script $thread_count_script $tomcat_host:$monitor_dir
   scp $monitor_script $kill_script $lock_script $thread_count_script $mysql_host:$monitor_dir   

   scp -r $cur_dir/$rubbos_client_dir $client_host:/tmp
   scp -r $cur_dir/elba-httpd-2.4-conf $httpd_host:/tmp/httpd-conf
   scp -r $cur_dir/RUBBoS-Server $tomcat_host:/tmp
   scp -r $cur_dir/tomcat-logs $tomcat_host:/tmp
   scp -r $cur_dir/tomcat-conf $tomcat_host:/tmp

   scp -r $cur_dir/mysql-conf $mysql_host:/tmp
}

delFiles(){
  ssh $client_host "sudo rm -r /tmp/$rubbos_client_dir;";
  ssh $httpd_host  "sudo rm -r /tmp/httpd-conf; sudo rm -r $monitor_dir; sudo rm $lock_log-*; sudo rm $thread_count_log-* ";
  ssh $tomcat_host "sudo rm -r /tmp/RUBBoS-Server; sudo rm -r /tmp/tomcat-logs; sudo rm -r /tmp/tomcat-conf; sudo rm -r $monitor_dir; sudo rm $lock_log-*; sudo rm $thread_count_log-*"
  ssh $mysql_host  "sudo rm -r /tmp/mysql-conf; sudo rm -r $monitor_dir; sudo rm $lock_log-*; sudo rm $thread_count_log-*";
  #cd $cur_dir; 
  sudo rm -r $rubbos_client_dir; sudo rm -r $monitor_dir;
}

delRCSVC(){
  kubectl delete rc httpd-controller
  kubectl delete rc tomcat-controller
  kubectl delete rc mysql-controller
  kubectl delete rc rubbos-client-controller

  kubectl delete svc httpd-service
  kubectl delete svc tomcat-service
  kubectl delete svc mysql-service
}

startPods(){
   cd $cur_dir;
   kubectl create -f httpd-service.yaml
   kubectl create -f elba-httpd-controller.yaml
   kubectl create -f tomcat-service.yaml
   kubectl create -f tomcat-controller.yaml
   kubectl create -f mysql-service.yaml
   kubectl create -f mysql-controller.yaml
   kubectl create -f rubbos-client-controller.yaml
   sleep 2m
}

ready(){
        error_num=0
	pods=($(kubectl get pods --namespace $namespace |  awk 'NR>1 { printf sep $3; sep=" "}'))
	if [ ${#pods[@]} -gt 0 ]; then  # $n is still undefined!
	    #returns each item as a separate word in pods
	    for pod in "${pods[@]}"; do
		if [[ $pod == "Running" ]]; then
	  	   echo $pod, "Running"
		else
                   echo "To sleep"
                   sleep 30s   
                   error_num=$(($error_num+1))
		fi
	    done
	fi
        return $error_num
}

deploy(){
    ready
    error_num=$?
    echo "error number of pods" $error_num
    if [[ error_num -gt 0 ]]; then
       echo "Readying"
       ready
    else
       echo "Ready to run"
    fi
    sleep 1m
}

run(){
   echo "run rubbos client"
   #startCollectl
   client_pod=($(kubectl get pods --namespace $namespace -o wide| grep rubbos-client-controller| awk 'NR>0 { printf sep $1; sep=" "}'))
   echo "rubbos client pod" ${client_pod[0]}
   if [ ${#client_pod[@]} -gt 0 ]; then
       echo $execution_dir/$run_script
       kubectl exec -it ${client_pod[0]} $execution_dir/$run_script
   else
      echo "there is no client"
      return -1
   fi   
}

transFiles(){
   result_host=$master_host
   dest_dir=/tmp/results/$storage;
   ssh $result_host "mkdir -p $dest_dir"
   ssh $client_host "scp -r /tmp/$rubbos_client_dir/bench $result_host:$dest_dir";
   ssh $httpd_host  "scp -r /tmp/httpd-conf $result_host:$dest_dir";
   ssh $tomcat_host "scp -r /tmp/tomcat-logs $result_host:$dest_dir";

   cp -r $monitor_dir $dest_dir;
   ssh $httpd_host  "scp -r $monitor_dir $result_host:$dest_dir";
   ssh $tomcat_host "scp -r $monitor_dir $result_host:$dest_dir";
   ssh $mysql_host  "scp -r $monitor_dir $result_host:$dest_dir";

   cp  $lock_log-* $dest_dir;
   ssh $httpd_host  "scp -r $lock_log-* $thread_count_log-* $result_host:$dest_dir";
   ssh $tomcat_host "scp -r $lock_log-* $thread_count_log-* $result_host:$dest_dir";
   ssh $mysql_host  "scp -r $lock_log-* $thread_count_log-* $result_host:$dest_dir";

}

update_workload(){
  cd $cur_dir
  sudo rm -r $rubbos_client_dir
  cp -r RUBBoS-Client $rubbos_client_dir

  cd $rubbos_client_dir/workload;
  if [ "$workload_mode" = "browse_only" ]; then
     cp  browse_only_transitions.txt        user_transitions.txt
     cp  browse_only_transitions.txt        author_transitions.txt
     #just for check later
     cp  browse_only_transitions.txt        ../bench
  else
     cp  user_default_transitions.txt       user_transitions.txt
     cp  author_default_transitions.txt     author_transitions.txt
     #just for check later
     cp  user_default_transitions.txt       ../bench
     cp  author_default_transitions.txt     ../bench
  fi
  cd $cur_dir
  cp $rubbos_client_dir/bench/$workload_property $rubbos_client_dir/Client/rubbos.properties
  #just for check later
  cp $rubbos_client_dir/Client/rubbos.properties $rubbos_client_dir/bench
  
}

uploadResults(){
   cd $cur_dir; cd ..
   sudo install gdrive /usr/local/bin/gdrive
   sudo zip -r /tmp/results.zip /tmp/results
   sudo /users/zcp/gdrive upload /tmp/results.zip
}

namespace=$1
#transFiles

test(){
   delFiles
   tomcat_confs=(server-default.xml server-500.xml server-1000.xml)
   mysql_confs=(my-default.cnf my-250.cnf my-500.cnf)
   for count in 0; do
    cp /tmp/webapp/tomcat-conf/${tomcat_confs[$count]} /tmp/webapp/tomcat-conf/server.xml
    cp /tmp/webapp/mysql-conf/${mysql_confs[$count]}   /tmp/webapp/mysql-conf/my.cnf
    for mode in browse_only mix; do
      clean_monitor
      for property in rubbos.properties_100 rubbos.properties_500 rubbos.properties_1000 rubbos.properties_1500 rubbos.properties_2000 rubbos.properties_2500 rubbos.properties_3000 rubbos.properties_3500 rubbos.properties_4000 rubbos.properties_5000; do
      #for property in rubbos.properties_100; do
         DATE=`date '+%Y-%m-%d-%H-%M-%S'`
         storage=$count-$mode-$property-$DATE
         workload_mode=$mode
         workload_property=$property
         update_workload
         copyFiles
         delRCSVC
         startPods
         deploy
         echo "start collectl on hosts"
         start_monitor
         run
         echo "clean collectl on hosts"
         clean_monitor
         transFiles
         cp /tmp/webapp/tomcat-conf/${tomcat_confs[$count]} $storage
         cp /tmp/webapp/mysql-conf/${mysql_confs[$count]}   $storage
         delFiles
         delRCSVC
      done
      clean_monitor
     done
   done
   uploadResults
}

test
#transFiles
#echo copy files to hosts
#delFiles
#echo cpoy Files
#copyFiles
#echo delete files from hosts
#delFiles
#start_monitor
#clean_monitor

