# Docker Machine Centos

## What is the problem?

Connecting a docker-machine to a vagrant box running centos is not well documented.

Like me have you asked the question:
- How do I control version of docker on a docker-machine?
- How do I control version of docker on Boot2docker?

## What does it do?

* Install vagrant plugin: vagrant-vbguest
  * To have vagrant use folder synced from host
* Vagrant up
  * Install docker and docker-compose version you select
* Update ssh known_hosts
* Create docker-machine 'generic' connecting to Vagrant machine running Centos
  * using engine-install-url="" to not override version of docker installed during vagrant up


### Set Up

Install docker-machine

```
curl -L https://github.com/docker/machine/releases/download/v0.7.0/docker-machine-`uname -s`-`uname -m` >/usr/local/bin/docker-machine && \
chmod +x /usr/local/bin/docker-machine
```

Run script
```
git clone git@github.com:pabvenegas/docker-machine-centos.git
cd docker-machine-centos

# 1. Adjust variables in file ./init.sh
#    ## set up variables - start

# 2. Adjust variables in file /scripts/init.sh
#    To control docker and docker-compose versions
#    to be installed.

# 3. Run init.sh
./init.sh

```

### Post Set Up

```
# 1. Enable ssh agent forwarding
vi ~/.ssh/config

Host 192.168.99.201
  User vagrant
  Forwardagent yes
  ServerAliveInterval 60
  StrictHostKeyChecking no
  IdentityFile ~/path-to-repo/docker-machine-centos/.vagrant/machines/docker_dev/virtualbox/private_key
  GSSAPIAuthentication no
  IdentitiesOnly yes

# 2. From Mac host
# connect via normal ssh
# NOT docker-machine ssh or vagrant ssh
ssh 192.168.99.201
ssh -i .vagrant/machines/docker_dev/virtualbox/private_key vagrant@192.168.99.201

ssh-add -l
# output showing forwarded ssh keys

sudo -i

# https://docs.docker.com/engine/admin/systemd/
> ls -l /etc/docker/
> systemctl show --property=FragmentPath docker
> cat /etc/systemd/system/docker.service

```

## Known errors

### Vagrant 1.8.5 bug with Centos 7 ssh

Error during vagrant up: "default: Warning: Authentication failure. Retrying..."
- https://github.com/mitchellh/vagrant/issues/7610
  - For anybody else who could benefit, the location to manually patch on Mac is
/opt/vagrant/embedded/gems/gems/vagrant-1.8.5/plugins/guests/linux/cap/public_key.rb.
- Apply fix https://github.com/mitchellh/vagrant/pull/7611/commits/a6760dd8e7743e048cb2f38c474e05889356e8ac
  - Add new line at line 57
  - chmod 0600 ~/.ssh/authorized_keys
