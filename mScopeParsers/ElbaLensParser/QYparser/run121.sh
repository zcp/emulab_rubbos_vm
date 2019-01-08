#!/bin/bash

timeSpan=$1
startTime=$2
endTime=$3
workload=$4

python BO.py $timeSpan $startTime $endTime $workload Apache
python BO.py $timeSpan $startTime $endTime $workload Tomcat
python BO.py $timeSpan $startTime $endTime $workload Tomcat1
python BO.py $timeSpan $startTime $endTime $workload Tomcat2
python BO.py $timeSpan $startTime $endTime $workload Mysql
