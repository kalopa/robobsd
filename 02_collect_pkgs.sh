#!/bin/sh
#
# Script to run inside Vagrant VM (FreeBSD 12.4) and build all three
# OS images.
#
set -ex

export ABI=FreeBSD:12:i386
export NANO_PACKAGE_LIST="\
	pkg-1.19.0 \
	indexinfo-0.3.1 \
	libedit-3.1.20221030,1 \
	libffi-3.4.4 \
	libunwind-20211201_1 \
	libyaml-0.2.5 \
	m4-1.4.19,1 \
	perl5-5.32.1_3 \
	autoconf-switch-20220527 \
	autoconf-2.71 \
	automake-1.16.5 \
	binutils-2.39,1 \
	tcl86-8.6.13 \
	expect-5.45.4_4,1 \
	dejagnu-1.6.3 \
	gettext-runtime-0.21.1 \
	libtextstyle-0.21.1 \
	gettext-tools-0.21.1 \
	gmake-4.3_2 \
	mpdecimal-2.5.1 \
	sudo-1.9.13p1 \
	libiconv-1.17 \
	liblz4-1.9.4,1 \
	xxhash-0.8.1_2 \
	zstd-1.5.2_1 \
	rsync-3.2.7 \
	ruby-3.0.5,1 \
	ruby30-gems-3.3.26 \
	rubygem-rake-13.0.6 \
	readline-8.2.0 \
	python39-3.9.16 \
	python3-3_3 \
	mpfr-4.1.1 \
	mpc-1.2.1 \
	gmp-6.2.1 \
	gcc12-12.2.0_5 \
	redis-7.0.8 \
	"

echo ">> Collect PKG files..."
cd /home/vagrant/robobsd
mkdir -p packages/All ../images
chown -R root:wheel ./cfg ./data
chown -R 1000:1000 ./data/robobsd
chmod 755 ./data/robobsd
chmod -R go-rwx ./data/robobsd/.ssh

pkg fetch -y -o packages $NANO_PACKAGE_LIST

echo "Done!"
exit 0
