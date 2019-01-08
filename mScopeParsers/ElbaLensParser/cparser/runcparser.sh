#!/bin/bash

#many of these parameters could be generated automatically
#in particular, the source code generator could automatically generate the list of log files

#generate separate files so that components files requests at component level are separated


data_process_dir=$1
target_dir=$2

#nclient=$3
#napache=$4
#ntomcat=$5
#nmysql=$6


if [[ $# -ne 2 ]] ; then
    echo "Usage : $0 directory_to_process target_dir"
    exit 1
fi

cp $data_process_dir/*access.log.gz .
cp $data_process_dir/*servlets.log.gz .
cp $data_process_dir/*response*.log.gz .
cp $data_process_dir/trace_client*.html .

echo "processing Client files"
#./Clientparser $nclient $napache
./Clientparser 4 1

mv DBImport-Apache.csv nodes_CLIENT_request.csv

echo "processing Apache files"
gzip -d *HTTPD*_access.log.gz

#for ((i=1;i<=$napache;i++)); do
for apachefile in *_"HTTPD"*"_access.log" ; do
  echo $apachefile 
  #apachefile="HTTPD"$i"_access.log"
  #./Apacheparser $apachefile QueueLength-Tomcat.csv DBImport-Tomcat.csv
  ./Apacheparser $apachefile
done

echo "processing Tomcat files"
gzip -d *TOMCAT*_access.log.gz
gzip -d *TOMCAT*_servlets.log.gz

#$JAVA_HOME/bin/java -Xmx8000m -XX:-UseGCOverheadLimit -jar ApacheLogSeparator.jar ./ $ntomcat

#for ((i=1;i<=$ntomcat;i++)); do
for tomcatfile in *"_TOMCAT"*"_access.log" ; do
  echo $tomcatfile
  accessfile=$tomcatfile
  #accessfile="TOMCAT"$i"_access.log"
  servletfile=`echo $tomcatfile | awk -F'[_.]' '{print $1"_"$2"_"$3"_servlets."$(NF)}'`
  echo $servletfile
  #servletfile="TOMCAT"$i"_servlets.log"
  #./Tomcatparser $accessfile $servletfile
  #./Tomcatparser $accessfile $servletfile QueueLength-CJDBC.csv DBImport-CJDBC.csv
  $JAVA_HOME/bin/java TomcatParser $accessfile $servletfile QueueLength-CJDBC.csv
done


#for ((i=0;i<$napache;i++)); do
#  apachesepfile="HTTPD_access_TOMCAT"$i".log"
#  let "j = i+1"
#  output="QueueLength-Tomcat"$j".csv"
#  ./Apacheparser $apachefile $output
#done

echo "processing CJDBC files"
gzip -d *CJDBC*_response*.log.gz

for cjdbcfile in *"_CJDBC"*".log" ; do
  #./CJDBCparser $cjdbcfile QueueLength-MySQL.csv DBImport-MySQL.csv
  ./CJDBCparser $cjdbcfile
done

rm ./*.log
rm ./*.gz
rm ./*.html

echo $target_dir
cp ./*.csv $target_dir
rm *.csv

echo "Done processing component logs"
