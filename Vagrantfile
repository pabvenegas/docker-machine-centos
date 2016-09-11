unless Vagrant.has_plugin?("vagrant-vbguest")
  raise 'vbguest plugin is not installed! Run - vagrant plugin install vagrant-vbguest'
end

Vagrant.configure(2) do |config|

  config.vm.box = "centos/7"
  config.vm.box_check_update = false
  config.vm.network "private_network", ip: "192.168.99.201"

  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--memory", 1792]
  end

  # vagrant plugin install vagrant-vbguest
  config.vm.define "docker_dev" do |docker_dev|
    docker_dev.vm.synced_folder "/Users/pvenegas/data_docker_dev", "/data"
    docker_dev.vm.provision "shell", path: "scripts/init.sh"
  end

end