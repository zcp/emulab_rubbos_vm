#!/bin/bash
echo generate prepare.sh
echo "#!/bin/bash" > prepare.sh
cat hosts_info >> prepare.sh
cat prepare.template >> prepare.sh
sudo chmod +x prepare.sh

echo generate install_kubernetes.sh
echo "#!/bin/bash" > install_kubernetes.sh
cat hosts_info >> install_kubernetes.sh
cat install_kubernetes.template >> install_kubernetes.sh
sudo chmod +x install_kubernetes.sh


echo generate init_kubernetes.sh
echo "#!/bin/bash" > init_kubernetes.sh
cat hosts_info >> init_kubernetes.sh
cat init_kubernetes.template >> init_kubernetes.sh
sudo chmod +x init_kubernetes.sh

echo generate start_install_kubernetes.sh
echo "#!/bin/bash" > start_install_kubernetes.sh
cat hosts_info >> start_install_kubernetes.sh
cat start_install_kubernetes.template >> start_install_kubernetes.sh
sudo chmod +x start_install_kubernetes.sh

echo generate start_init_kubernetes.sh
echo "#!/bin/bash" > start_init_kubernetes.sh
cat hosts_info >> start_init_kubernetes.sh
cat start_init_kubernetes.template >> start_init_kubernetes.sh
sudo chmod +x start_init_kubernetes.sh

echo generate emulab-run_rubbos.sh
echo "#!/bin/bash" > emulab-run_rubbos.sh
cat hosts_info >> emulab-run_rubbos.sh
cat emulab-run_rubbos.template >> emulab-run_rubbos.sh
sudo chmod +x emulab-run_rubbos.sh

echo generate start_emulab-run_rubbos.sh
echo "#!/bin/bash" > start_emulab-run_rubbos.sh
cat hosts_info >> start_emulab-run_rubbos.sh
cat start_emulab-run_rubbos.template >> start_emulab-run_rubbos.sh
sudo chmod +x start_emulab-run_rubbos.sh

echo generate update_rubbos_conf.sh
echo "#!/bin/bash" > update_rubbos_conf.sh
cat hosts_info >> update_rubbos_conf.sh
cat update_rubbos_conf.template >> update_rubbos_conf.sh
sudo chmod +x update_rubbos_conf.sh
