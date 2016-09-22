# RoboBSD
Configuration files for creating a RoboBSD compact flash image
specifically for a robotic environment.
The flash image is an almost-identical derivative of NanoBSD,
which is documented in the
[NanoBSD Howto](https://www.freebsd.org/doc/en/articles/nanobsd/howto.html "NanoBSD Howto from the FreeBSD Manual"))

Assuming you have Vagrant installed, and you have a FreeBSD Vagrant box which works (I built my own), you can simply run

    vagrant up

and it will bring up the freebsd10\_1 Vagrant box, and run the RoboBSD build script.

If Vagrant isn't working for you, or you're on a native FreeBSD install, you
can simply run the following command:

    sh robobsd.sh -c alix.nano

To produce a CF image for a PC Engines ALIX board.

The ALIX kernel is highly tuned to the ALIX board with all extraneous drivers removed.
You may want to make adjustments here, as needed.
A good place to start is to modify the _alex.nano_ file to use the GENERIC kernel
and once that is working, start eliminating unnecessary drivers.

If you're using Vagrant (and I'd recommend it), you can use buildbox.sh to take the resultant
vagrant disk image, and create a Vagrant box which will work on Virtualbox.
