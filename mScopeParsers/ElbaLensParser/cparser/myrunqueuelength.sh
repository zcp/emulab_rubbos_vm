#!/bin/bash

timeSpan=$1
startTime=$2
endTime=$3
workload=$4
workload_type=$5
cur_dir=$6

cd /home/zcp/emulab/mScopeParsers/ElbaLensParser/cparser
cp BO.py $cur_dir
cd $cur_dir

python BO.py $timeSpan $startTime $endTime $workload $workload_type Apache
python BO.py $timeSpan $startTime $endTime $workload $workload_type Tomcat
python BO.py $timeSpan $startTime $endTime $workload $workload_type CJDBC 
#python BO.py $timeSpan $startTime $endTime $workload $workload_type Mysql

rm BO.py
