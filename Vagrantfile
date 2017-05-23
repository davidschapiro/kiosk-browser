# workaround for vagrant-share error: vagrant plugin install vagrant-share --plugin-version 1.1.8 (from https://github.com/mitchellh/vagrant/issues/8519)
#
# you need the reload plugin: vagrant plugin install vagrant-reload
#
# then vagrant up
#

nodes = [
  { :hostname => 'debian', :box => 'debian/contrib-jessie64', :ram => 1024 },
  { :hostname => 'ubuntu', :box => 'ubuntu/xenial64', :ram => 1024 },
]

$script = <<SCRIPT
set -ex
mount | grep vbox
echo "deb [ trusted=yes ] copy:/packages /" >/etc/apt/sources.list.d/vagrant.list
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y install kiosk-browser
SCRIPT

Vagrant.configure(2) do |config|
  nodes.each do |node|
    config.vm.define node[:hostname] do |nodeconfig|
      nodeconfig.vm.box = node[:box]
      nodeconfig.vm.provider "virtualbox"
      nodeconfig.vm.hostname = node[:hostname] + ".box"
#      nodeconfig.ssh.insert_key = false
      nodeconfig.vm.synced_folder "./", "/vagrant", disabled: true
      nodeconfig.vm.synced_folder "out/", "/packages", owner: "root", group: "root", mount_options: ["dmode=777,fmode=666"]
      nodeconfig.vm.synced_folder ".deps/apt_archives/", "/var/cache/apt/archives/", create: true,  owner: "root", group: "root", mount_options: ["dmode=775,fmode=664"]
      nodeconfig.vm.provider :virtualbox do |prov|
        prov.gui = true unless ENV['NO_GUI']
        prov.customize ["modifyvm", :id, "--boot1", "DVD", "--boot2", "disk",
                              "--boot3", "none", "--boot4", "none"]

      end
      nodeconfig.vm.provision "shell", inline: $script
      nodeconfig.vm.provision :reload
    end
  end
end

# -*- mode: ruby -*-
# vi: set ft=ruby