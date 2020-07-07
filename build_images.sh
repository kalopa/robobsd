#!/bin/sh
#
# Script to run inside Vagrant VM (FreeBSD 12.1) and build all three
# OS images.
#
set -e

export ABI=FreeBSD:12:i386
export NANO_PACKAGE_LIST="\
	pkg-1.13.2_1 \
	indexinfo-0.3.1 \
	libedit-3.1.20191211,1 \
	libffi-3.2.1_3 \
	libunwind-20170615 \
	libyaml-0.2.2 \
	m4-1.4.18_1,1 \
	perl5-5.30.3 \
	autoconf-wrapper-20131203 \
	autoconf-2.69_3 \
	automake-1.16.1_2 \
	binutils-2.33.1_2,1 \
	dejagnu-1.6.2 \
	tcl86-8.6.10 \
	expect-5.45.4_2,1 \
	gettext-runtime-0.20.1 \
	libtextstyle-0.20.1 \
	gettext-tools-0.20.1_1 \
	gmake-4.2.1_3 \
	sudo-1.8.31p1 \
	libiconv-1.14_11 \
	rsync-3.1.3_1 \
	ruby-2.6.5,1 \
	ruby26-gems-3.0.6 \
	rubygem-rake-12.3.3 \
	"

cd /home/vagrant/robobsd
mkdir -p packages ../images
chown -R root:wheel ./cfg ./data
chown -R 1000:1000 ./data/robobsd
chmod 755 ./data/robobsd
chmod -R go-rwx ./data/robobsd/.ssh
svnlite checkout --non-interactive --trust-server-cert-failures=unknown-ca https://svn.FreeBSD.org/base/releng/12.1 /usr/src
pkg fetch -y -o packages $NANO_PACKAGE_LIST

flags=""
for system in *.nano
do
	sh /usr/src/tools/tools/nanobsd/nanobsd.sh -c $system $flags
	flags="-w"
done
exit 0
