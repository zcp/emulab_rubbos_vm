#!/bin/bash

#nclient=$1
#napache=$2
#ntomcat=$3
data_process_dir=$1
target_dir=$2
curr_dir=`pwd`
parser_dir=$curr_dir"/ServiceTimeParser"
#NODE_NAME="node"
#JAVA_HOME=/export/hp530/projects/elba/tao/jdk1.7.0

if [[ $# -ne 2 ]] ; then
    echo "Usage : $0 directory_to_process target_dir"
    exit 1
fi

cp $data_process_dir/*.csv .

echo "processing DST files"
for dstfile in *.csv ; do
  ./WaitTime $dstfile
done

echo "copying results"
cp *dst.csv $target_dir
rm *.csv
echo "Done"
