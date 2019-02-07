#!/bin/bash
#./thread_count.sh filter_word result_save
filter_keyword=$1
result=$2-"`hostname`"-$filter_keyword

thread_count(){
   container_ids=($(sudo docker ps | grep $filter_keyword | awk 'NR>0 { printf sep $1; sep=" "}'))
   echo container count,${#container_ids[@]}
   declare -A container_pids
   if [ ${#container_ids[@]} -gt 0 ]; then  # $n is still undefined!
      container_id=${container_ids[0]}
      container_pid=$(sudo docker inspect --format '{{ .State.Pid }}' $container_id)
      #echo \#`date +"%Y-%m-%d-%H:%M:%S:%3N"` > $result
      while : 
      do
          timestamp=`date +"%Y-%m-%d,%H:%M:%S.%3N"`
          thread_count=$(cat /proc/$container_pid/status | grep Threads)
          echo $timestamp, $thread_count  >> $result
          
          #echo  $result-thread-count-$filter_keyword
          #nice -n  1 cat /proc/$container_pid/status | grep Threads >> $result
          #nice -n  1 ls /proc/$container_pid/fd/ | wc -l >> $result
          #ps -o nlwp $container_pid
          # >> $result-thread-count-$filter_keyword
          sleep 1
          #echo \#`date +"%Y-%m-%d-%H:%M:%S.%3N"` >> $result 

      done
   fi
}



thread_count
