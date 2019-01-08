#!/bin/bash


rubbos_properties_path=/home/zcp/emulab/webapp/RUBBoS-Client/Client/rubbos.properties
dest_dir=/home/zcp/emulab/webapp/RUBBoS-Client/bench
for workload in 100 200 300 400 500 600 700 800 900 1000 1500 2000 2200 2500 2800 3000 3200 3500 3600 3800 4000; do
    sed -i "s/^workload_number_of_clients_per_node.*/workload_number_of_clients_per_node=$workload/" $rubbos_properties_path
    cp $rubbos_properties_path $dest_dir/rubbos.properties_$workload
done

