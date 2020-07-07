# RoboBSD - An embedded FreeBSD for Robotics

Configuration files for creating a RoboBSD compact flash image
specifically for a robotic environment.
The flash image is a derivative of NanoBSD,
which is documented in the
[NanoBSD Howto](https://www.freebsd.org/doc/en/articles/nanobsd/howto.html)
from the FreeBSD Manual.

## Building the images using Vagrant

Assuming you have [Vagrant](https://www.vagrantup.com/)
installed, you can simply run

    $ vagrant up

and it will bring up the freebsd12\_1-RELEASE Vagrant box.
Note that there does seem to be some issues with FreeBSD on startup so
I have decoupled the build step from the Vagrantfile.

Once the VM is up and running, you can run the build script manually:

    $ ./build.sh

In this instance it will create three images, one for Vagrant debugging work,
a disk image for the
[PC Engines](http://pcengines.ch/)
[ALIX](http://pcengines.ch/alix.htm) board and a disk image for the
[WRAP](http://pcengines.ch/wrap.htm) board (which is no longer produced).

You will need the Vagrant plug-in for
[SCP](https://github.com/invernizzi/vagrant-scp).
Also, I use Vagrant with Virtualbox, so YMMV if you're using
a different virtualization platform.

## The build scripts

The *build.sh* script copies the required build scripts to the new
Vagrant VM, and executes the *build_images.sh* script on the VM to do
the actual build work.
The *build_images.sh* script, running locally on the FreeBSD VM,
will pull the */usr/src* tree from the FreeBSD SVN repository
(with the tag *releng/12.1*).
It will then pull all of the required packages, ready for installation.
Once that is complete, it will run the *nanobsd.sh* tool (provided
with the FreeBSD source tools) to build three, fresh install images.

## Retrieving the disk images

Once the Vagrant VM has produced the three images,
you can copy them to your home directory using the following commands:

    $ vagrant scp :images/robobsd.vagrant.img.gz .
    $ vagrant scp :images/robobsd.alix.img.gz .
    $ vagrant scp :images/robobsd.wrap.img.gz .

These images are compressed and can be copied to a Compact Flash as follows:

    $ gunzip robobsd.alix.img
    $ dd if=robobsd.alix.img bs=10m of=/dev/da1

NOTE I used */dev/da1* in this example - make sure you specify the right device here).
I'll repeat that - **make sure you specify the right device**.

You can also use *build_vbox.sh* to copy the vagrant disk image from the VM file system,
and create a Vagrant box which will work on Virtualbox.

Failing that, you can download a copy
[here](http://dload.kalopa.com/robobsd/robobsd.box.gz).
To install this, use the following:

    $ curl -O http://dload.kalopa.com/robobsd/robobsd.box.gz
    $ gunzip robobsd.box
    $ vagrant box add --name robobsd ./robobsd.box

If you have installed an older version of this Vagrant box,
you will need to use the _--force_ option to replace it.
This Vagrant box uses the default Vagrant insecure key so make sure you change the key and
the default password.

If you are looking for raw Compact Flash images for PC Engines boards, try here:

    $ curl -O http://dload.kalopa.com/robobsd/robobsd.alix.img.gz
    $ curl -O http://dload.kalopa.com/robobsd/robobsd.wrap.img.gz

As created, there is a user account _robobsd_ with password _vagrant_ on the image.

## Installed packages

The following packages have been pre-installed:

* autoconf: 2.69\_3
* autoconf-wrapper: 20131203
* automake: 1.16.1\_2
* binutils: 2.33.1\_2,1
* dejagnu: 1.6.2
* expect: 5.45.4\_2,1
* gettext-runtime: 0.20.1
* gettext-tools: 0.20.1\_1
* gmake: 4.2.1\_3
* indexinfo: 0.3.1
* libedit: 3.1.20191211,1
* libffi: 3.2.1\_3
* libiconv: 1.14\_11
* libtextstyle: 0.20.1
* libunwind: 20170615
* libyaml: 0.2.2
* m4: 1.4.18\_1,1
* perl5: 5.30.3
* pkg: 1.13.2\_1
* rsync: 3.1.3\_1
* ruby: 2.6.5,1
* ruby26-gems: 3.0.6
* rubygem-rake: 12.3.3
* sudo: 1.8.31p1
* tcl86: 8.6.10

## Running RoboBSD on Vagrant

To use the newly-created robobsd Vagrant box, create a separate directory and copy the
following into a file called _Vagrantfile_ in there.

    # -*- mode: ruby -*-
    # vi: set ft=ruby :

    Vagrant.configure(2) do |config|
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

    $ socat - UNIX-CONNECT:/tmp/robo_com1 

If you're using the board to interface to a low-level system, you can simulate that
system using the Unix-domain sockets.

Here's some Ruby code to read from COM1:

    #!/usr/bin/env ruby
    #
    require 'socket'

    socket = UNIXSocket.new("/tmp/robo_com1")

    while(line = socket.gets) do
      puts line
    end

## Issues / Contributions

Feel free to
[create an issue](https://github.com/kalopa/robobsd/issues/new)
if/when you discover a problem.
I'm always open to pull requests if you have a bug fix, a new idea, a newly-supported platform
or whatever.
