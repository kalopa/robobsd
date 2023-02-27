#!/bin/sh
#
# Script to run inside Vagrant VM (FreeBSD 12.4) and build all three
# OS images.
#
set -ex

export ABI=FreeBSD:12:i386

echo ">> Get FreeBSD source from SVN..."
svnlite checkout --non-interactive --trust-server-cert-failures=unknown-ca https://svn.FreeBSD.org/base/releng/12.4 /usr/src

# :FIXME: deal with slight bug in nanobsd.sh
patch -d /usr/src/tools/tools/nanobsd defaults.sh <<'EOF'
*** defaults.sh.orig	2023-02-13 14:07:07.407045249 +0000
--- defaults.sh	2023-02-13 14:13:15.361731914 +0000
***************
*** 780,785 ****
--- 780,786 ----
  
  	# Mount packages into chroot
  	mkdir -p ${NANO_WORLDDIR}/_.p
+ 	cp /etc/resolv.conf ${NANO_WORLDDIR}/etc/resolv.conf
  	mount -t nullfs -o noatime -o ro ${NANO_PACKAGE_DIR} ${NANO_WORLDDIR}/_.p
  	mount -t devfs devfs ${NANO_WORLDDIR}/dev
  
EOF
echo "Done!"
exit 0
