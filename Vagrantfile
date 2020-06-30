# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# This is a Vagrant configuration to spin up a standard FreeBSD system,
# and build a RoboBSD disk image.
#
# NB: I have run into virtualbox extension issues with the latest
# FreeBSD vagrant boxen. I know it works (more or less) with
# VirtualBox version 5.1.22, but beyond that, you're on your own.
# It should also work with libvirt (with some modifications) but I
# need to run the build env on Linux and Mac OS X, so I use VB.
#
# The build system will produce three images, as follows:
#    1. RoboBSD for Vagrant
#    2. RoboBSD for a PC Engines ALIX board
#    3. RoboBSD for a PC Engines WRAP board
#
$files = %w{cfg data kernel packages vagrant.nano alix.nano wrap.nano}

$nanobsd = <<SCRIPT
sudo chown -R root:wheel /home/vagrant/robobsd/cfg /home/vagrant/robobsd/data
sudo chown -R 1000:1000 /home/vagrant/robobsd/data/robobsd
sudo chmod 755 /home/vagrant/robobsd/data/robobsd
sudo chmod -R go-rwx /home/vagrant/robobsd/data/robobsd/.ssh
sudo sh /usr/src/tools/tools/nanobsd/nanobsd.sh -c /home/vagrant/robobsd/vagrant.nano
sudo sh /usr/src/tools/tools/nanobsd/nanobsd.sh -c /home/vagrant/robobsd/alix.nano -w
sudo sh /usr/src/tools/tools/nanobsd/nanobsd.sh -c /home/vagrant/robobsd/wrap.nano -w
SCRIPT

Vagrant.configure(2) do |config|
  config.vm.hostname = "robodev"
  config.vm.box = "freebsd/FreeBSD-12.1-RELEASE"
  config.vm.box_version = "2017.07.21"
  config.vm.base_mac = "080027D14C66"
  config.vm.guest = :freebsd
  config.vm.network "forwarded_port", guest: 22, host: 8022
  config.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true
  config.ssh.shell = "sh"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
    vb.customize ["modifyvm", :id, "--cpus", "4"]
    vb.customize ["modifyvm", :id, "--audio", "none"]
  end

  $files.each do |file|
    config.vm.provision "file", source: file, destination: "robobsd/#{file}"
  end
  config.vm.provision "bootstrap", type: "shell", inline: $nanobsd
end
