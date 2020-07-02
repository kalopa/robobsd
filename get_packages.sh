#!/bin/sh
#
set -e

PACKAGES="\
	pkg-1.13.2_1 \
	libedit-3.1.20191211,1 \
	libffi-3.2.1_3 \
	libunwind-20170615 \
	libyaml-0.2.2 \
	autoconf-2.69_3 \
	autoconf-wrapper-20131203 \
	automake-1.16.1_2 \
	binutils-2.33.1_2,1 \
	dejagnu-1.6.2 \
	expect-5.45.4_2,1 \
	gmp-6.2.0 \
	gcc-ecj-4.5 \
	gcc9-9.3.0 \
	gettext-runtime-0.20.1 \
	libtextstyle-0.20.1 \
	gettext-tools-0.20.1_1 \
	gmake-4.2.1_3 \
	sudo-1.8.31p1 \
	rsync-3.1.3_1 \
	ruby-2.6.5,1 \
	ruby26-gems-3.0.6 \
	tcl86-8.6.10 \
	texinfo-6.7_2,1 \
	help2man-1.47.13 \
	indexinfo-0.3.1 \
	libiconv-1.14_11 \
	m4-1.4.18_1,1 \
	mpc-1.1.0_2 \
	mpfr-4.0.2 \
	perl5-5.30.3 \
	p5-Locale-gettext-1.07 \
	p5-Locale-libintl-1.31 \
	p5-Text-Unidecode-1.30 \
	p5-Unicode-EastAsianWidth-12.0 \
	redis-5.0.8
"

export ABI=FreeBSD:12:i386

rm -rf log/ packages/
mkdir -p log packages
pkg fetch -y -o packages $PACKAGES
exit 0
