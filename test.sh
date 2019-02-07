#!/bin/bash
pid=$1
      while : 
      do
          #echo  $result-thread-count-$filter_keyword
          timestamp=`date +"%Y-%m-%d,%H:%M:%S.%3N"`
          thread_count=$(cat /proc/$pid/status | grep Threads)
          nice -n 1 echo $timestamp, $thread_count  >> test.txt
          #ps -o nlwp $container_pid
          # >> $result-thread-count-$filter_keyword
          sleep 1
          #echo \#`date +"%Y-%m-%d-%H:%M:%S.%3N"` >> $result 
      done

