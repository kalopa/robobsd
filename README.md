# RoboBSD - An embedded FreeBSD for Robotics

Configuration files for creating a RoboBSD compact flash image
specifically for a robotic environment.
The flash image is a derivative of NanoBSD,
which is documented in the
[NanoBSD Howto](https://www.freebsd.org/doc/en/articles/nanobsd/howto.html)
from the FreeBSD Manual.

## Downloading pre-built images

If you don't want to go through the hassle of building images for the ALIX,
WRAP and Vagrant systems, the following are available for download:

* [Vagrant Box](https://kalopa.com/download/robobsd/robobsd-12.4-kr2.box.gz)
* [ALIX](https://kalopa.com/download/robobsd/robobsd-12.4-kr2.alix.img.gz)
* [WRAP](https://kalopa.com/download/robobsd/robobsd-12.4-kr2.wrap.img.gz)

## Running RoboBSD on Vagrant

To use the *robobsd* Vagrant box, create a separate directory and copy the
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
[here](https://kalopa.com/download/robobsd/robobsd-12.4-kr2.box.img.gz).
To install this, use the following:

    $ curl -O https://kalopa.com/download/robobsd/robobsd-12.4-kr2.box.img.gz
    $ gunzip robobsd-12.4-kr2.box.img
    $ vagrant box add --name robobsd ./robobsd-12.4-kr2.box.img

If you have installed an older version of this Vagrant box,
you will need to use the _--force_ option to replace it.
This Vagrant box uses the default Vagrant insecure key so make sure you change the key and
the default password.

If you are looking for raw Compact Flash images for PC Engines boards, try here:

    $ curl -O https://kalopa.com/download/robobsd/robobsd-12.4-kr2.alix.img.gz
    $ curl -O https://kalopa.com/download/robobsd/robobsd-12.4-kr2.wrap.img.gz

As created, there is a user account _robobsd_ with password _vagrant_ on the image.

# Virtual Machine

If Vagrant isn't your cup of tea, try the following QEMU command:

    $ qemu-system-i386 -nographic -drive file=robobsd.alix.img,format=raw

(Remember to uncompress the image file, beforehand).
To exit out of QEMU emulation, type **^Ax**.

## Installed packages

The following packages have been pre-installed:

* autoconf: 2.71
* autoconf-switch: 20220527
* automake: 1.16.5
* binutils: 2.39,1
* dejagnu: 1.6.3
* expect: 5.45.4\_4,1
* gcc12: 12.2.0\_5
* gettext-runtime: 0.21.1
* gettext-tools: 0.21.1
* gmake: 4.3\_2
* gmp: 6.2.1
* indexinfo: 0.3.1
* libedit: 3.1.20221030,1
* libffi: 3.4.4
* libiconv: 1.17
* liblz4: 1.9.4,1
* libtextstyle: 0.21.1
* libunwind: 20211201\_1
* libyaml: 0.2.5
* m4: 1.4.19,1
* mpc: 1.2.1
* mpdecimal: 2.5.1
* mpfr: 4.1.1
* perl5: 5.32.1\_3
* pkg: 1.19.0
* python3: 3\_3
* python39: 3.9.16
* readline: 8.2.0
* redis: 7.0.8
* rsync: 3.2.7
* ruby: 3.0.5,1
* ruby30-gems: 3.3.26
* rubygem-rake: 13.0.6
* sudo: 1.9.13p1
* tcl86: 8.6.13
* xxhash: 0.8.1\_2
* zstd: 1.5.2\_1

## Issues / Contributions

Feel free to
[create an issue](https://github.com/kalopa/robobsd/issues/new)
if/when you discover a problem.
I'm always open to pull requests if you have a bug fix, a new idea, a newly-supported platform
or whatever.
