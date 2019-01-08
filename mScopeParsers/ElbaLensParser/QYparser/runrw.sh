#!/bin/bash

timeSpan=$1
startTime=$2
endTime=$3
workload=$4

python RW.py $timeSpan $startTime $endTime $workload Apache
python RW.py $timeSpan $startTime $endTime $workload Tomcat
python RW.py $timeSpan $startTime $endTime $workload Mysql
