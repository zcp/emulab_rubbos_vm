#!/bin/bash
remote_host=$1

#scp grub $1:/users/zcp
scp hosts $1:/users/zcp

#scp -r webapp $1:/users/zcp

#scp install_kubernetes.sh $1:/users/zcp
#scp init_kubernetes.sh $1:/users/zcp
#scp emulab-run_rubbos.sh $1:/users/zcp
#scp kube-flannel_eth0.yml $1:/users/zcp


#ssh -p 22 $1 "cd /users/zcp; sudo cp grub /etc/default/; sudo update-grub;"
ssh -p 22 $1 "cd /users/zcp; sudo cp hosts /etc/hosts"


#ssh -p 22 $1 "sudo reboot"

