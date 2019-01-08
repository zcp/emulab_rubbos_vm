#!/bin/bash

source $HOME/.bashrc

#check the number of command line parameters
if [[ $# -eq 2 ]] ; then
    data_process_dir=$1
    target_dir=$2
elif [[ $# -eq 1 ]] && [[ -n "$DATA_TARGET" ]] ; then
    data_process_dir=$1
    target_dir=$DATA_TARGET
else
    echo "Usage : $0 directory_to_process (target directory)"
    echo "Directoy to process should be a complete path to an Experimental Result directory"
    exit 1
fi

#check to make sure environment variables exist and are set
if [[ -z "$DATATOOLS_HOME" ]] || [[ -z "$VIRTUAL_ENV" ]] ; then
    echo "milliScope tools have not been built; run build.sh"
    exit 1
fi

echo "clear target directory"
rm -rf $target_dir

echo "creating data processing target directory"
mkdir $target_dir

curr_dir=$DATATOOLS_HOME/mScopeParsers

intermediate_dir=$DATATOOLS_HOME/wip

intermediate_subdir=$intermediate_dir/component_files

echo "processing data inputs"

echo "activating python environment"

source $VIRTUAL_ENV/bin/activate

#iterate over all workload sub-directories
for sdir in $data_process_dir/*; do
        
    mkdir -p $intermediate_subdir
    
    cd $curr_dir

    workload_dir="$(basename $sdir)"
    
    workload_target=$target_dir/$workload_dir
    
    mkdir -p $workload_target
    
    echo "processing component logs for extract requests"
    
    cd ElbaLensParser/cparser

    #write component files - outputs - to /component_files
    #TO DO: does passing number of nodes: m Apache, n Tomcat, k MySql, 1 CJDBC yield any benefit?
    ./runcparser.sh $sdir $intermediate_subdir
    
    cd $curr_dir
    
    echo "processing point-in-time"
    
    cd PointintimeParser
    
    #process Apache component file to produce PiT response time calculations
    ./runpitime.sh $intermediate_subdir $workload_target
    
    cd $curr_dir
    
    echo "processing queue lengths"

    FILE=$sdir/stat_client0.html
    
    WORKLOAD=`echo $workload_dir | awk -F'[-]' '{print $1}'`
    WORKLOADTYPE=`echo $workload_dir | awk -F'[-]' '{print $2}'`

    cd ElbaLensParser/QYparser

    #process QueueLength files in intermediate_dir and output to target    
    ./runqueuelength.sh $WORKLOAD $WORKLOADTYPE $FILE $intermediate_subdir $workload_target

    cd $curr_dir
    
    cd mScopeTransform
    
    #clean up working directory before processing resource data
    rm -rf $intermediate_dir/*
    
    echo "processing collectl"

    #copy collectl files to processing location
    cp $sdir/data/*coll* $intermediate_dir
    
    #process collectl monitor files
    ./transform/collectl_multifile_parser.py $intermediate_dir $workload_target
    
    echo "cleaning up intermediate results"
    rm -rf $intermediate_dir
done

echo "Done"
