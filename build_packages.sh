#!/bin/sh
#
set -e

PACKAGES="\
	autoconf-2.69_1 \
	autoconf-wrapper-20131203 \
	automake-1.15.1 \
	automake-wrapper-20131203 \
	dejagnu-1.6.1 \
	expect-5.45.4,1 \
	gettext-runtime-0.19.8.1_1 \
	gettext-tools-0.19.8.1 \
	gmake-4.2.1_2 \
	help2man-1.47.6 \
	indexinfo-0.3.1 \
	libedit-3.1.20170329_2,1 \
	libffi-3.2.1_2 \
	libiconv-1.14_11 \
	libyaml-0.1.6_2 \
	m4-1.4.18,1 \
	p5-Locale-gettext-1.07 \
	perl5.24-5.24.4 \
	pkg-1.10.5_1 \
	redis-4.0.9_1 \
	rsync-3.1.3 \
	ruby23-2.3.7,1 \
	ruby24-gems-2.7.6 \
	sudo-1.8.23_2 \
	tcl86-8.6.8 \
	texinfo-6.5,1 \
	rubygem-bundler-1.16.1 \
"

rm -rf log/ packages/
mkdir -p log packages

for package in $PACKAGES
do
    echo ">>>> $package"
    pkg fetch -y -o packages $package
done
exit 0
