# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  
  config.ssh.insert_key = false
  config.ssh.paranoid = false
  config.vm.define "node1" do |node1|
    node1.vm.box = "centos/7"
    node1.vm.hostname = "node1"
    node1.vm.network "private_network", ip: "192.168.2.10"
    node1.vm.network "private_network", ip: "192.168.44.10"
  end
  config.vm.define "node2" do |node2|
    node2.vm.box = "centos/7"
    node2.vm.hostname = "node2"
    node2.vm.network "private_network", ip: "192.168.2.11"
    node2.vm.network "private_network", ip: "192.168.44.11"
  end
  config.vm.define "node3" do |node3|
    node3.vm.box = "centos/7"
    node3.vm.hostname = "node3"
    node3.vm.network "private_network", ip: "192.168.2.12"
    node3.vm.network "private_network", ip: "192.168.44.12"
  end
  config.vm.define "node4" do |node4|
    node4.vm.box = "centos/7"
    node4.vm.hostname = "node4"
    node4.vm.network "private_network", ip: "192.168.2.13"
    node4.vm.network "private_network", ip: "192.168.44.13"
  end
  config.vm.define "node5" do |node5|
    node5.vm.box = "centos/7"
    node5.vm.hostname = "node5"
    node5.vm.network "private_network", ip: "192.168.2.14"
    node5.vm.network "private_network", ip: "192.168.44.14"
  end
  config.vm.provider "virtualbox" do |vb|
     vb.memory = "4096"
     vb.linked_clone = true
  end
end
