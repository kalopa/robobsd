#!/bin/sh
#
set -e

PACKAGES="\
	autoconf-2.69_3 \
	autoconf-wrapper-20131203 \
	automake-1.16.1_2 \
	binutils-2.32_1,1 \
	dejagnu-1.6.2 \
	expect-5.45.4_1,1 \
	gcc-ecj-4.5 \
	gcc9-9.2.0 \
	gettext-runtime-0.20.1 \
	gettext-tools-0.20.1_1 \
	gmake-4.2.1_3 \
	gmp-6.1.2_1 \
	help2man-1.47.11 \
	indexinfo-0.3.1 \
	libedit-3.1.20190324,1 \
	libffi-3.2.1_3 \
	libiconv-1.14_11 \
	libunwind-20170615 \
	libyaml-0.2.2 \
	m4-1.4.18_1,1 \
	mpc-1.1.0_2 \
	mpfr-4.0.2 \
	p5-Locale-gettext-1.07 \
	perl5-5.30.0 \
	pkg-1.12.0 \
	redis-4.0.14_1 \
	rsync-3.1.3_1 \
	ruby-2.6.5,1 \
	ruby26-gems-3.0.6 \
	sudo-1.8.28 \
	tcl86-8.6.9_1 \
	texinfo-6.6_4,1 \
"

rm -rf log/ packages/
mkdir -p log packages

for package in $PACKAGES
do
    echo ">>>> $package"
    pkg fetch -y -o packages $package
done
exit 0
