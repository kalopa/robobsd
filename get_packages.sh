#!/bin/sh
#
set -e

PACKAGES="\
	autoconf-2.69_1 \
	autoconf-wrapper-20131203 \
	automake-1.15.1 \
	automake-wrapper-20131203 \
	binutils-2.30_2,1 \
	dejagnu-1.6.1 \
	expect-5.45.4,1 \
	gcc-ecj-4.5 \
	gcc6-6.4.0_4 \
	gettext-runtime-0.19.8.1_1 \
	gettext-tools-0.19.8.1 \
	gmake-4.2.1_2 \
	gmp-6.1.2 \
	help2man-1.47.6 \
	indexinfo-0.3.1 \
	libedit-3.1.20170329_2,1 \
	libffi-3.2.1_2 \
	libiconv-1.14_11 \
	libunwind-20170615 \
	libyaml-0.1.6_2 \
	m4-1.4.18,1 \
	mpc-1.1.0 \
	mpfr-3.1.6 \
	p5-Locale-gettext-1.07 \
	perl5-5.26.2 \
	pkg-1.10.5 \
	redis-3.2.11 \
	rsync-3.1.3 \
	ruby-2.4.4,1 \
	ruby24-gems-2.7.6 \
	rubygem-bundler-1.16.1 \
	sudo-1.8.22 \
	tcl86-8.6.8 \
	texinfo-6.5,1 \
"

rm -rf log/ packages/
mkdir -p log packages

for package in $PACKAGES
do
    echo ">>>> $package"
    pkg fetch -y -o packages $package
done
exit 0
