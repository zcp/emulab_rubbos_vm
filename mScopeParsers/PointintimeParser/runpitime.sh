#!/bin/bash

#nclient=$1
#napache=$2
#ntomcat=$3
data_process_dir=$1
target_dir=$2
curr_dir=`pwd`
parser_dir=$curr_dir"/PointintimeParser"
#NODE_NAME="node"
#JAVA_HOME=/export/hp530/projects/elba/tao/jdk1.7.0

if [[ $# -ne 2 ]] ; then
    echo "Usage : $0 directory_to_process target_dir"
    exit 1
fi

echo "processing pit file"
#for pitfile in *.csv ; do
$JAVA_HOME/bin/java PointInTimeParser $data_process_dir
#done

#echo "copying results"
cp $data_process_dir/Pointintime.csv $target_dir
echo "Done"
