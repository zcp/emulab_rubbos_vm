#!/bin/bash

#many of these parameters could be generated automatically
#in particular, the source code generator could automatically generate the list of log files

#generate separate files so that components files requests at component level are separated


data_process_dir=$1
target_dir=$2
client_log=client.log
apache_log=access_log
tomcat_log=localhost.log-clear
servlets_log=rubbos-servlets.log-clear


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

tomcatParser(){
    echo $tomcat_log $servlets_log 
    suffix="_request.csv"
    #java TomcatParser $tomcat_log $servlets_log QueueLength-mysql.csv
    ./myTomcatparser.o $tomcat_log $servlets_log 
    cp $tomcat_log$suffix  QueueLength-CJDBC-orig.csv
    cut --delimiter=',' -f2-5 $tomcat_log$suffix > QueueLength-CJDBC.csv

}

transFiles(){
   mkdir -p $target_dir
   mv *.csv $target_dir
}

cd /home/zcp/emulab/mScopeParsers/ElbaLensParser/cparser
copyFiles
clientParser
apacheParser
tomcatParser
transFiles
delFiles
