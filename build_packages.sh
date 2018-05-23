#!/bin/sh
#
set -e

PACKAGES="\
	ports-mgmt/pkg \
	print/indexinfo \
	converters/libiconv \
	devel/libedit \
	textproc/libyaml \
	devel/gettext-runtime \
	devel/gettext-tools \
	devel/gmake \
	net/rsync \
	security/sudo \
	lang/perl5.24 \
	devel/p5-Locale-gettext \
	misc/help2man \
	print/texinfo \
	devel/m4 \
	devel/autoconf-wrapper \
	devel/autoconf \
	devel/automake-wrapper \
	devel/automake \
	lang/tcl86 \
	lang/expect \
	misc/dejagnu \
	devel/libffi \
	lang/ruby23 \
	devel/ruby-gems \
	databases/redis \
"

rm -rf log/ packages/
mkdir -p log packages

for package in $PACKAGES
do
    echo ">>>> $package"
    mkdir -p log/$package
    make -C /usr/ports/$package -DBATCH package > log/$package/build.log 2>&1
    cp /usr/ports/$package/work/pkg/${basic}*.txz packages/
done
exit 0
