#!/bin/tcsh

###############################################################################
#
# This script runs first the RUBBoS browsing mix, then the read/write mix 
# for each rubbos.properties_XX specified where XX is the number of emulated
# clients. Note that the rubbos.properties_XX files must be configured
# with the corresponding number of clients.
# In particular set the following variables in rubis.properties_XX:
# httpd_use_version = Servlets
# workload_number_of_clients_per_node = XX/number of client machines
# workload_transition_table = yourPath/RUBBoS/workload/transitions.txt 
#
# This script should be run from the RUBBoS/bench directory on the local 
# client machine. 
# Results will be generated in the RUBBoS/bench directory.
#
################################################################################

setenv SERVLETDIR $RUBBOS_HOME/Servlets

# Go back to RUBBoS root directory
cd ..

# Browse only

cp --reply=yes ./workload/browse_only_transitions.txt ./workload/user_transitions.txt
cp --reply=yes ./workload/browse_only_transitions.txt ./workload/author_transitions.txt

scp ./workload/browse_only_transitions.txt ${CLIENT1_HOST}:${RUBBOS_HOME}/workload/user_transitions.txt
scp ./workload/browse_only_transitions.txt ${CLIENT1_HOST}:${RUBBOS_HOME}/workload/author_transitions.txt

scp ./workload/browse_only_transitions.txt ${CLIENT2_HOST}:${RUBBOS_HOME}/workload/user_transitions.txt
scp ./workload/browse_only_transitions.txt ${CLIENT2_HOST}:${RUBBOS_HOME}/workload/author_transitions.txt

scp ./workload/browse_only_transitions.txt ${CLIENT3_HOST}:${RUBBOS_HOME}/workload/user_transitions.txt
scp ./workload/browse_only_transitions.txt ${CLIENT3_HOST}:${RUBBOS_HOME}/workload/author_transitions.txt


foreach i (rubbos.properties_1 rubbos.properties_2 rubbos.properties_3 rubbos.properties_4 rubbos.properties_5 rubbos.properties_6 rubbos.properties_7 rubbos.properties_8 rubbos.properties_9 rubbos.properties_10 rubbos.properties_11 rubbos.properties_12 rubbos.properties_13 rubbos.properties_14 )
#foreach i (rubbos.properties_100 rubbos.properties_200 rubbos.properties_300 rubbos.properties_400 rubbos.properties_500)


  # restart all services
  cd $WORK_HOME/rubbos
  ./stop_all.sh
  sleep 15
  ./start_all.sh
  sleep 15
  cd -
  

  cp --reply=yes bench/$i Client/rubbos.properties
  scp bench/$i ${CLIENT1_HOST}:${RUBBOS_HOME}/Client/rubbos.properties
  scp bench/$i ${CLIENT2_HOST}:${RUBBOS_HOME}/Client/rubbos.properties
  scp bench/$i ${CLIENT3_HOST}:${RUBBOS_HOME}/Client/rubbos.properties


      
  bench/flush_cache 490000
  ssh $HTTPD_HOST "$RUBBOS_HOME/bench/flush_cache 880000" 	# web server
  ssh $MYSQL_HOST "$RUBBOS_HOME/bench/flush_cache 880000"	# database
  ssh $TOMCAT_HOST "$RUBBOS_HOME/bench/flush_cache 780000" 	# servlet server
  ssh $CLIENT1_HOST "$RUBBOS_HOME/bench/flush_cache 490000"	# remote client
  ssh $CLIENT2_HOST "$RUBBOS_HOME/bench/flush_cache 490000"	# remote client
  ssh $CLIENT3_HOST "$RUBBOS_HOME/bench/flush_cache 490000"	# remote client
  make emulator
end



# Read/write mix

cp --reply=yes ./workload/user_default_transitions.txt ./workload/user_transitions.txt
cp --reply=yes ./workload/author_default_transitions.txt ./workload/author_transitions.txt

scp ./workload/user_default_transitions.txt ${CLIENT1_HOST}:${RUBBOS_HOME}/workload/user_transitions.txt
scp ./workload/author_default_transitions.txt ${CLIENT1_HOST}:${RUBBOS_HOME}/workload/author_transitions.txt

scp ./workload/user_default_transitions.txt ${CLIENT2_HOST}:${RUBBOS_HOME}/workload/user_transitions.txt
scp ./workload/author_default_transitions.txt ${CLIENT2_HOST}:${RUBBOS_HOME}/workload/author_transitions.txt

scp ./workload/user_default_transitions.txt ${CLIENT3_HOST}:${RUBBOS_HOME}/workload/user_transitions.txt
scp ./workload/author_default_transitions.txt ${CLIENT3_HOST}:${RUBBOS_HOME}/workload/author_transitions.txt


foreach i (rubbos.properties_1 rubbos.properties_2 rubbos.properties_3 rubbos.properties_4 rubbos.properties_5 rubbos.properties_6 rubbos.properties_7 rubbos.properties_8 rubbos.properties_9 rubbos.properties_10 rubbos.properties_11 rubbos.properties_12 rubbos.properties_13 rubbos.properties_14 )


  # restart all services
  cd $WORK_HOME/rubbos
  ./stop_all.sh
  sleep 15
  ./start_all.sh
  sleep 15
  cd -


  cp --reply=yes bench/$i Client/rubbos.properties
  scp bench/$i ${CLIENT1_HOST}:${RUBBOS_HOME}/Client/rubbos.properties
  scp bench/$i ${CLIENT2_HOST}:${RUBBOS_HOME}/Client/rubbos.properties
  scp bench/$i ${CLIENT3_HOST}:${RUBBOS_HOME}/Client/rubbos.properties


      
  bench/flush_cache 490000
  ssh $HTTPD_HOST "$RUBBOS_HOME/bench/flush_cache 880000" 	# web server
  ssh $MYSQL_HOST "$RUBBOS_HOME/bench/flush_cache 880000"	# database
  ssh $TOMCAT_HOST "$RUBBOS_HOME/bench/flush_cache 780000" 	# servlet server
  ssh $CLIENT1_HOST "$RUBBOS_HOME/bench/flush_cache 490000"	# remote client
  ssh $CLIENT2_HOST "$RUBBOS_HOME/bench/flush_cache 490000"	# remote client
  ssh $CLIENT3_HOST "$RUBBOS_HOME/bench/flush_cache 490000"	# remote client
  make emulator
end

# stopping all services
cd $WORK_HOME/rubbos
./stop_all.sh
 
