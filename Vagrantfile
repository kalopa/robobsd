# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# This is a Vagrant configuration to spin up a standard FreeBSD system,
# and build a RoboBSD disk image.
#
$files = %w{cfg data kernel packages vagrant.nano alix.nano wrap.nano}

$nanobsd = <<SCRIPT
sudo chown -R root:wheel /home/vagrant/robobsd/cfg /home/vagrant/robobsd/data
sudo chown -R 1000:1000 /home/vagrant/robobsd/data/robobsd
sudo chmod -R go-rwx /home/vagrant/robobsd/data/robobsd/.ssh
sudo sh /usr/src/tools/tools/nanobsd/nanobsd.sh -c /home/vagrant/robobsd/vagrant.nano
sudo sh /usr/src/tools/tools/nanobsd/nanobsd.sh -c /home/vagrant/robobsd/alix.nano -w
sudo sh /usr/src/tools/tools/nanobsd/nanobsd.sh -c /home/vagrant/robobsd/wrap.nano -w
SCRIPT

Vagrant.configure(2) do |config|
  config.vm.hostname = "robodev"
  config.vm.box = "FreeBSD10_1"
  config.vm.guest = :freebsd
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
