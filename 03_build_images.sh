#!/bin/sh
#
# Script to run inside Vagrant VM (FreeBSD 12.4) and build all three
# OS images.
#
set -ex

export ABI=FreeBSD:12:i386

echo ">> Building images..."
cd /home/vagrant/robobsd

cp kernel/* /usr/src/sys/i386/conf

flag="-w"
for system in *.nano
do
	echo ">>> Building image for $system..."
	sh /usr/src/tools/tools/nanobsd/nanobsd.sh -c $system $flag
	flag="-w"
done
echo "Done!"
exit 0
