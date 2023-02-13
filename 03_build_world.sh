#!/bin/sh
#
# Script to run inside Vagrant VM (FreeBSD 12.4) and build all three
# OS images.
#
set -ex

export ABI=FreeBSD:12:i386

echo ">> Build World (everything but the kernel)..."
cd /home/vagrant/robobsd

cp kernel/* /usr/src/sys/i386/conf
sh /usr/src/tools/tools/nanobsd/nanobsd.sh -c alix.nano -k -K
echo "Done!"
exit 0
