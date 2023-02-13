#!/bin/sh
#
# Script to run inside Vagrant VM (FreeBSD 12.4) and build all three
# OS images.
#
set -ex

export ABI=FreeBSD:12:i386

echo ">> Get FreeBSD source from SVN..."
cd /home/vagrant/robobsd
svnlite checkout --non-interactive --trust-server-cert-failures=unknown-ca https://svn.FreeBSD.org/base/releng/12.4 /usr/src
echo "Done!"
exit 0
