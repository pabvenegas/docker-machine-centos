#! /bin/bash

function reset()
{
  docker-machine rm docker-dev -y
  vagrant destroy -f
}

function main()
{
  #########################################
  ## set up variables - start

  vagrant_ip_address="192.168.99.201"
  local_folder="/Users/${USER}/data_docker_dev"
  vagrant_folder="/data"
  # underscore in name below not accepted by docker-machine create
  docker_machine_name=docker-dev
  # replace strings
  vagrant_config_vm_network="config.vm.network \"private_network\", ip: \"${vagrant_ip_address}\""
  vagrant_synced_folder="docker_dev.vm.synced_folder \"${local_folder}\", \"${vagrant_folder}\""

  ## set up variables - end
  #########################################

  echo "------------------"
  echo "vagrant 1.8.5 check known error fix applied"
  echo "------------------"
  vagrant --version | grep "1.8.5"
  if [ $? -eq 0 ]; then
    echo "Have you applied known error fix detailed in README for Vagrant 1.8.5 and Centos?"
    echo "ENTER 'y' to continue OR 'n' to exit"
    read fix_continue;

    if [ "${fix_continue}" == "n" ]; then
      echo "Exiting";
      exit 1
    fi
  fi

  echo "------------------"
  echo "vagrant plugin for shared folder"
  echo "------------------"
  vagrant plugin list | grep vagrant-vbguest
  if [ $? -ne 0 ]; then
    vagrant plugin  install vagrant-vbguest
  else
    echo "Skipping - vagrant plugin 'vagrant-vbguest' already installed"
  fi

  echo "------------------"
  echo "check docker-machine does not already exist"
  echo "------------------"
  docker-machine ls | grep ${docker_machine_name}
  if [ $? -eq 0 ]; then
    echo ""
    echo "Docker-machine ${docker_machine_name} already exists please remove or rename to proceed"
    exit 1
  fi

  if [ ! -d "${local_folder}" ]; then
    mkdir -p ${local_folder}
  fi

  sed -i '' -e "s/config.vm.network.*/${vagrant_config_vm_network}/g" Vagrantfile
  # Using ~ as delimiter
  sed -i '' -e "s~docker_dev.vm.synced_folder.*$~${vagrant_synced_folder}~g" Vagrantfile

  echo "------------------"
  echo "vagrant up"
  echo "------------------"
  vagrant up

  echo "------------------"
  echo "Update ssh known_hosts"
  echo "------------------"
  # remove existing value from known_hosts file
  ssh-keygen -R ${vagrant_ip_address}
  # add new entry to known_hosts file
  ssh-keyscan -H ${vagrant_ip_address} >> ~/.ssh/known_hosts

  echo "------------------"
  echo "Verify ssh connection"
  echo "------------------"
  vagrant ssh -c 'docker --version && docker-compose -v'
  vagrant ssh -c "systemctl status docker.service"

  echo "------------------"
  echo "Docker-machine create"
  echo "NOTE: this may take some time"
  echo "------------------"
  # engine-install-url is set to empty
  # so default script from get.docker.com is not running
  # overriding our installed docker version
  # use "docker-machine -D create" to show DEBUG notes

  docker_machine_version=`docker-machine version | cut -d ' ' -f 3`
  if [ $docker_machine_version != "0.7.0," ]; then
    echo "ERROR: Currently only compatible with docker-machine version 0.7.0"
    echo "ERROR: Docker-machine not created."
    echo "ERROR: Current docker-machine version = ${docker_machine_version}"
  else
    docker-machine create -d generic \
    --generic-ssh-user=vagrant \
    --generic-ssh-key=.vagrant/machines/docker_dev/virtualbox/private_key \
    --generic-ip-address=${vagrant_ip_address} \
    --engine-install-url="" \
      ${docker_machine_name}

    echo "------------------"
    echo "docker-machine-centos script complete"
    echo "------------------"

    echo "------------------"
    echo "Docker-machine connecting"
    echo "------------------"

    eval $(docker-machine env ${docker_machine_name})
    docker-machine ls | grep "*"

    echo "------------------"
    echo "docker version"
    echo "------------------"
    docker version
  fi
}

main