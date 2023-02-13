#!/bin/sh
#
# Script to run inside Vagrant VM (FreeBSD 12.4) and build all three
# OS images.
#
set -ex

export ABI=FreeBSD:12:i386

echo ">> Building kernel images..."
cd /home/vagrant/robobsd

cp kernel/* /usr/src/sys/i386/conf
for system in *.nano
do
	echo ">>> Building image for $system..."
	sh /usr/src/tools/tools/nanobsd/nanobsd.sh -c $system -w
done
echo "Done!"
exit 0
