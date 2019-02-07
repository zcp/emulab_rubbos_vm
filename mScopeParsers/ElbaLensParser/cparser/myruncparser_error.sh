#!/bin/bash

#many of these parameters could be generated automatically
#in particular, the source code generator could automatically generate the list of log files

#generate separate files so that components files requests at component level are separated


data_process_dir=$1
target_dir=$2
client_log=client.log_error
apache_log=access_log_error
tomcat_log=localhost.log_error
servlets_log=rubbos-servlets.log_error-clear


copyFiles(){
    cp $data_process_dir/$client_log .
    cp $data_process_dir/$apache_log .
    cp $data_process_dir/$tomcat_log .
    cp $data_process_dir/$servlets_log .
}

delFiles(){
   rm $client_log
   rm $apache_log
   rm $tomcat_log
   rm $servlets_log
}

clientParser(){
  ./myClientparser.o 1 1
  mv DBImport-Apache.csv nodes_CLIENT_request.csv
  java PointInTimeParser . 
}

apacheParser(){
   ./Apacheparser.o $apache_log
}



transFiles(){
   mkdir -p $target_dir
   mv *.csv $target_dir
}

cd /home/zcp/emulab/mScopeParsers/ElbaLensParser/cparser
copyFiles
#clientParser
apacheParser

transFiles
delFiles
