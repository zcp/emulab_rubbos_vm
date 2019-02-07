#!/bin/bash


rubbos_properties_path=/home/zcp/emulab/webapp/RUBBoS-Client/Client/rubbos.properties
dest_dir=/home/zcp/emulab/webapp/RUBBoS-Client/bench
for workload in 100 200 300 400 500 600 700 800 900 1000 1100 1200 1300 1400 1500 2000 2500 3000 5000 8000 10000 12000 13000 14000 15000 16000; do
    sed -i "s/^workload_number_of_clients_per_node.*/workload_number_of_clients_per_node=$workload/" $rubbos_properties_path
    cp $rubbos_properties_path $dest_dir/rubbos.properties_$workload
done

