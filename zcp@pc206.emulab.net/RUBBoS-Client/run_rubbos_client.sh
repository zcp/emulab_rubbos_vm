#!/bin/bash
database_server=192.168.110.3
client_server=192.168.110.5
master=192.168.110.2

rm ~/.ssh/id_rsa
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
public_key_file=~/.ssh/id_rsa.pub
public_key=$(cat $public_key_file)
password=123456

for remote_server in $database_server $client_server $master; do
    echo $remote_server
    sshpass -p $password ssh root@$remote_server "echo $public_key > /root/.ssh/authorized_keys"
done

cd /tmp/RUBBoS;
make emulator
