# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# This is a Vagrant configuration to spin up a standard FreeBSD system,
# and build a RoboBSD disk image.
#
$files = %w{app cfg data kernel packages robobsd.sh vagrant.nano alix.nano wrap.nano}

$nanobsd = <<SCRIPT
sudo sh /home/vagrant/robobsd/robobsd.sh -c /home/vagrant/robobsd/vagrant.nano
SCRIPT

Vagrant.configure(2) do |config|
  config.vm.guest = :freebsd
  config.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true
  config.vm.box = "FreeBSD10_1"
  config.ssh.shell = "sh"
  config.vm.hostname = "robodev"

  $files.each do |file|
    config.vm.provision "file", source: file, destination: "robobsd/#{file}"
  end
  config.vm.provision "bootstrap", type: "shell", inline: $nanobsd

  #config.vm.provider :virtualbox do |vb|
  #  vb.customize ["modifyvm", :id, "--memory", "1024"]
  #  vb.customize ["modifyvm", :id, "--cpus", "1"]
  #  vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
  #  vb.customize ["modifyvm", :id, "--audio", "none"]
  #  vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
  #  vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
  #end
end
