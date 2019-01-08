#!/bin/bash

timeSpan=$1
startTime=$2
endTime=$3
workload=$4
workload_type=$5

python BO.py $timeSpan $startTime $endTime $workload $workload_type Apache
python BO.py $timeSpan $startTime $endTime $workload $workload_type Tomcat
python BO.py $timeSpan $startTime $endTime $workload $workload_type CJDBC 
python BO.py $timeSpan $startTime $endTime $workload $workload_type Mysql
