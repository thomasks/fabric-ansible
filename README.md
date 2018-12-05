# fabric-ansible

#清空环境#
  docker stop $(docker ps -a -q) 
  docker  rm $(docker ps -a -q) //   remove删除所有容器
  docker rmi $(docker images |grep simple |awk '{print $3}')
  ansible-playbook -i inventories/freeexchange.cn/hosts -u root playbooks/manage_destroy.yml 
  ansible-playbook -i inventories/freeexchange.cn/hosts -u root playbooks/manage_k_z_stop.yml
  ansible-playbook -i inventories/freeexchange.cn/hosts -u root playbooks/manage_k_z_clean.yml
  ansible-playbook -i inventories/freeexchange.cn/hosts -u root clean_docker.yml 

#部署环境#
ansible-playbook -i inventories/freeexchange.cn/hosts -u root deploy_prepare.yml
ansible-playbook -i inventories/freeexchange.cn/hosts -u root deploy_nodes.yml
ansible-playbook -i inventories/freeexchange.cn/hosts -u root deploy_cli.yml



#停止fabric network#
  ansible-playbook -i inventories/freeexchange.cn/hosts -u root playbooks/manage_stop.yml
  ansible-playbook -i inventories/freeexchange.cn/hosts -u root playbooks/manage_k_z_stop.yml
  ansible-playbook -i inventories/freeexchange.cn/hosts -u root playbooks/manage_k_z_clean.yml
  ansible-playbook -i inventories/freeexchange.cn/hosts -u root deploy_prepare.yml
  ansible-playbook -i inventories/freeexchange.cn/hosts -u root playbooks/manage_rebuild.yml
