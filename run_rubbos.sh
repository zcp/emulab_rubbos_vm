#!/bin/bash
#run_rubbos namespace
client_host=192.168.110.5
httpd_host=192.168.110.5
tomcat_host=192.168.110.3
mysql_host=192.168.110.5
result_host=192.168.110.5
execution_dir=/tmp/RUBBoS
rubbos_client_dir=RUBBoS-Client-current
run_script=run_rubbos_client.sh
cur_dir=/home/zcp/emulab

monitor_dir=/tmp/monitor/
monitor=collectl.sh
kill_script=kill_bash.sh
collectl_cpu=$monitor_dir/cpu.txt
collectl_disk=$monitor_dir/disk.txt
collectl_mem=$monitor_dir/mem.txt
collectl_net=$monitor_dir/net.txt

start_monitor(){
    sshpass -p 123456 ssh $httpd_host "$monitor_dir/$monitor $collectl_cpu $collectl_mem $collectl_disk $collectl_net"
    sshpass -p 123456 ssh $tomcat_host "$monitor_dir/$monitor $collectl_cpu $collectl_mem $collectl_disk $collectl_net"
    #sshpass -p 123456 ssh $mysql_host "$monitor_dir/$mointor $collectl_cpu $collectl_mem $collectl_disk $collectl_net"
}

clean_monitor(){
    sshpass -p 123456 ssh $httpd_host "$monitor_dir/$kill_script collectl"
    sshpass -p 123456 ssh $tomcat_host "$monitor_dir/$kill_script collectl"
    #sshpass -p 123456 ssh $mysql_host "$monitor_dir/$kill_script collectl"   
}

copyFiles(){
   sshpass -p 123456 ssh root@$httpd_host "mkdir -p $monitor_dir"
   sshpass -p 123456 ssh root@$tomcat_host "mkdir -p $monitor_dir"
   #sshpass -p 123456 ssh root@$mysql_host "mkdir -p $monitor_dir"   

   sshpass -p 123456 scp $monitor $kill_script root@$httpd_host:$monitor_dir
   sshpass -p 123456 scp $monitor $kill_script root@$tomcat_host:$monitor_dir
   #sshpass -p 123456 scp $mointor $kill_script root@$mysql_host:$monitor_dir   

   sshpass -p 123456 scp -r $cur_dir/$rubbos_client_dir root@$client_host:/tmp
   sshpass -p 123456 scp -r $cur_dir/elba-httpd-2.4-conf root@$httpd_host:/tmp/httpd-conf
   sshpass -p 123456 scp -r $cur_dir/RUBBoS-Server root@$tomcat_host:/tmp
   sshpass -p 123456 scp -r $cur_dir/tomcat-logs root@$tomcat_host:/tmp
}

delFiles(){
  sshpass -p 123456 ssh root@$client_host "rm -r /tmp/$rubbos_client_dir";
  sshpass -p 123456 ssh root@$httpd_host  "rm -r /tmp/httpd-conf";
  sshpass -p 123456 ssh root@$tomcat_host "rm -r /tmp/RUBBoS-Server"
  sshpass -p 123456 ssh root@$tomcat_host "rm -r /tmp/tomcat-logs";
  cd $cur_dir; sudo rm -r $rubbos_client_dir
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
   echo "start collectl on hosts"
   start_monitor
   echo "run rubbos client"
   #startCollectl
   client_pod=($(kubectl get pods --namespace $namespace -o wide| grep rubbos-client-controller| awk 'NR>0 { printf sep $1; sep=" "}'))
   echo "rubbos client pod" ${client_pod[0]}
   if [ ${#client_pod[@]} -gt 0 ]; then
       echo $run_script
       kubectl exec -it ${client_pod[0]} $execution_dir/$run_script
   else
      echo "there is no client"
      return -1
   fi   
   echo "clean collectl on hosts"
   clean_monitor
}

transFiles(){
   dest_dir=/tmp/results/$storage;
   sshpass -p 123456 ssh root@$result_host "mkdir -p $dest_dir"
   sshpass -p 123456 ssh root@$client_host "sshpass -p 123456 scp -r /tmp/$rubbos_client_dir/bench root@$result_host:$dest_dir";
   sshpass -p 123456 ssh root@$httpd_host  "sshpass -p 123456 scp -r /tmp/httpd-conf root@$result_host:$dest_dir";
   sshpass -p 123456 ssh root@$tomcat_host "sshpass -p 123456 scp -r /tmp/tomcat-logs root@$result_host:$dest_dir";

   sshpass -p 123456 ssh root@$httpd_host  "sshpass -p 123456 scp -r $monitor_dir root@$result_host:$dest_dir";
   sshpass -p 123456 ssh root@$tomcat_host "sshpass -p 123456 scp -r $monitor_dir root@$result_host:$dest_dir";
   #sshpass -p 123456 ssh root@$mysql_host "sshpass -p 123456 scp -r $monitor_dir root@$result_host:$dest_dir";

}

update_workload(){
  cd $cur_dir
  sudo rm -r $rubbos_client_dir
  cp -r RUBBoS-Client $rubbos_client_dir

  cd $rubbos_client_dir/workload;
  if [ $workload_mode = "browse_only" ]; then
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


namespace=$1
#transFiles

test(){
   delFiles
   for mode in browse_only mix; do
      #for property in rubbos.properties_100 rubbos.properties_200 rubbos.properties_400 rubbos.properties_600 rubbos.properties_800; do
      for property in rubbos.properties_100; do
         storage=$mode-$property
         workload_mode=$mode
         workload_property=$property
         update_workload
         copyFiles
         delRCSVC
         startPods
         deploy
         run
         transFiles
         delFiles
         delRCSVC
      done
   done
}

test
#echo copy files to hosts
#copyFiles
#echo delete files from hosts
#delFiles

