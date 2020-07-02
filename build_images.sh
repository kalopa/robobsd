#!/bin/sh
#
# Script to run inside Vagrant VM (FreeBSD 12.1) and build all three
# OS images.
#
set -e

cd /home/vagrant/robobsd
mkdir -p packages ../images
chown -R root:wheel ./cfg ./data
chown -R 1000:1000 ./data/robobsd
chmod 755 ./data/robobsd
chmod -R go-rwx ./data/robobsd/.ssh
svnlite checkout --non-interactive --trust-server-cert-failures=unknown-ca https://svn.FreeBSD.org/base/releng/12.1 /usr/src
sh ./get_packages.sh
sh /usr/src/tools/tools/nanobsd/nanobsd.sh -c ./vagrant.nano
sh /usr/src/tools/tools/nanobsd/nanobsd.sh -c ./alix.nano -w
sh /usr/src/tools/tools/nanobsd/nanobsd.sh -c ./wrap.nano -w
exit 0
