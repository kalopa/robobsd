# RoboBSD
Configuration files for creating a RoboBSD compact flash image
specifically for a robotic environment.
The flash image is a derivative of NanoBSD,
which is documented in the
[NanoBSD Howto](https://www.freebsd.org/doc/en/articles/nanobsd/howto.html)
from the FreeBSD Manual.

Assuming you have Vagrant installed, and you have a FreeBSD Vagrant box
which works (I built my own), you can simply run

    vagrant up

and it will bring up the freebsd10\_1 Vagrant box, and run the RoboBSD build script.

In this instance it will create three images, one for Vagrant debugging work,
a disk image for the
[PC Engines](http://pcengines.ch/)
[ALIX](http://pcengines.ch/alix.htm) board and a disk image for the
[WRAP](http://pcengines.ch/wrap.htm) board (which is no longer produced).

You will need the Vagrant plug-in for
[SCP](https://github.com/invernizzi/vagrant-scp).
Also, I use Vagrant with Virtualbox, so YMMV if you're using
a different virtualization platform.

Once the Vagrant VM has produced the three images,
you can copy them to your home directory using the following commands:

	vagrant scp :/usr/obj/robobsd/vagrantdisk.img .
	vagrant scp :/usr/obj/robobsd/alixdisk.img .
	vagrant scp :/usr/obj/robobsd/wrapdisk.img .

These images are uncompressed and can be copied to a Compact Flash as follows:

	dd if=alixdisk.img bs=10m of=/dev/da1

(note I used */dev/da1* in this example - make sure you specify the right device here).

You can also use _buildbox.sh_ to copy the vagrant disk image from the VM file system,
and create a Vagrant box which will work on Virtualbox.

Failing that, you can download a copy
[here](http://kalopa.net/pub/robobsd.box).
To install this, use the following:

	curl -O http://www.kalopa.com/pub/robobsd.box
	vagrant box add --name robobsd ./robobsd.box

If you have installed an older version of this Vagrant box,
you will need to use the _--force_ option to replace it.
This Vagrant box uses the default Vagrant insecure key so make sure you change the key and
the default password.

As created, there is a user account _robobsd_ with password _vagrant_ on the image.

In addition, the following packages have been pre-installed:

	gettext-runtime-0.19.4
	indexinfo-0.2.3
	libedit-3.1.20150325_1
	libffi-3.2.1
	libyaml-0.1.6_2
	pkg-1.5.5
	redis-3.0.2
	rsync-3.1.1_3
	ruby-2.1.6,1
	ruby21-gems-2.4.8
	sudo-1.8.13

To use the newly-created robobsd Vagrant box, create a separate directory and copy the
following into a file called _Vagrantfile_ in there.

	# -*- mode: ruby -*-
	# vi: set ft=ruby :

	Vagrant.configure("2") do |config|
	  config.vm.box = "robobsd"
	  config.vm.hostname = "robobsd"
	  config.vm.guest = :freebsd
	  config.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true
	  config.ssh.shell = "sh"
	  config.ssh.username = "robobsd"

	  config.vm.provider :virtualbox do |vb|
	    vb.customize ["modifyvm", :id, "--uart1", "0x3f8", "4"]
	    vb.customize ["modifyvm", :id, "--uartmode1", "server", "/tmp/robo_com1"]
	    vb.customize ["modifyvm", :id, "--uart2", "0x2f8", "3"]
	    vb.customize ["modifyvm", :id, "--uartmode2", "server", "/tmp/robo_com2"]
	  end
	end

Two serial ports are created, for COM1 and COM2, as *RoboBSD* doesn't output anything to
the video console (the PC Engines boards don't have any VGA circuitry).
I use the following command to monitor what's happening as the machine boots.

	socat - UNIX-CONNECT:/tmp/robo_com1 

If you're using the board to interface to a low-level system, you can simulate that
system using the Unix-domain sockets.

Feel free to get in touch if you run into any issues.
