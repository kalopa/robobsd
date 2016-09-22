#!/bin/sh
#
# Copyright (c) 2016 Kalopa Research.
#
# RoboBSD is basically a tuned version of NanoBSD. In fact,
# about 99.9% of the code in this file is directly from
# /usr/src/tools/tools/nanobsd/nanobsd.sh
#
# Copyright (c) 2005 Poul-Henning Kamp.
# All rights reserved.
#
# Adapted by Dermot Tynan for RoboBSD purposes.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# $FreeBSD: releng/10.1/tools/tools/nanobsd/nanobsd.sh 266441 2014-05-19 10:08:05Z thomas $
#

set -e

#######################################################################
#
# Setup default values for all controlling variables.
# These values can be overridden from the config file(s)
#
#######################################################################

# Name of this RoboBSD build.  (Used to construct workdir names)
ROBO_NAME=full

# Source tree directory
ROBO_SRC=/usr/src

# Where RoboBSD additional files live under the source tree
ROBO_TOOLS=tools/tools/nanobsd

# Where cust_pkg() finds packages to install
ROBO_PACKAGE_DIR=${ROBO_SRC}/${ROBO_TOOLS}/Pkg
ROBO_PACKAGE_LIST="*"

# where package metadata gets placed
ROBO_PKG_META_BASE=/var/db

# Object tree directory
# default is subdir of /usr/obj
#ROBO_OBJ=""

# The directory to put the final images
# default is ${ROBO_OBJ}
#ROBO_DISKIMGDIR=""

# Make & parallel Make
ROBO_MAKE="make"
ROBO_PMAKE="make -j 3"

# The default name for any image we create.
ROBO_IMGNAME="_.disk.full"

# Options to put in make.conf during buildworld only
CONF_BUILD=' '

# Options to put in make.conf during installworld only
CONF_INSTALL=' '

# Options to put in make.conf during both build- & installworld.
CONF_WORLD=' '

# Kernel config file to use
ROBO_KERNEL=GENERIC

# Kernel modules to install. If empty, no modules are installed.
# Use "default" to install all built modules.
ROBO_MODULES=

# Customize commands.
ROBO_CUSTOMIZE=""

# Late customize commands.
ROBO_LATE_CUSTOMIZE=""

# Newfs paramters to use
ROBO_NEWFS="-b 4096 -f 512 -i 8192 -U"

# The drive name of the media at runtime
ROBO_DRIVE=ad0

# Target media size in 512 bytes sectors
ROBO_MEDIASIZE=2000000

# 0 -> Leave second image all zeroes so it compresses better.
# 1 -> Initialize second image with a copy of the first
ROBO_INIT_IMG2=1

# Size of code file system in 512 bytes sectors
# If zero, size will be as large as possible.
ROBO_CODESIZE=0

# Size of the app file system in 512 byte sectors
# If zero: no partion configured.
ROBO_APPSIZE=0

# Size of configuration file system in 512 bytes sectors
# Cannot be zero.
ROBO_CONFSIZE=2048

# Size of app file system in 512 byte sectors
# If zero: no partition configured.
NANO_APPSIZE=0

# Size of data file system in 512 bytes sectors
# If zero: no partition configured.
# If negative: max size possible
ROBO_DATASIZE=0

# Size of the /etc ramdisk in 512 bytes sectors
ROBO_RAM_ETCSIZE=10240

# Size of the /tmp+/var ramdisk in 512 bytes sectors
ROBO_RAM_TMPVARSIZE=10240

# Media geometry, only relevant if bios doesn't understand LBA.
ROBO_SECTS=63
ROBO_HEADS=16

# boot0 flags/options and configuration
ROBO_BOOT0CFG="-o packet -s 1 -m 3"
ROBO_BOOTLOADER="boot/boot0sio"

# boot2 flags/options
# default force serial console
ROBO_BOOT2CFG="-h"

# Backing type of md(4) device
# Can be "file" or "swap"
ROBO_MD_BACKING="file"

# for swap type md(4) backing, write out the mbr only
ROBO_IMAGE_MBRONLY=true

# Progress Print level
PPLEVEL=3

# Set ROBO_LABEL to non-blank to form the basis for using /dev/ufs/label
# in preference to /dev/${ROBO_DRIVE}
# Root partition will be ${ROBO_LABEL}s1
# /app partition will be $ROBO_LABEL}s2
# /cfg partition will be ${ROBO_LABEL}s3
# /data partition will be ${ROBO_LABEL}s4
ROBO_LABEL=""

#######################################################################
# Architecture to build.  Corresponds to TARGET_ARCH in a buildworld.
# Unfortunately, there's no way to set TARGET at this time, and it
# conflates the two, so architectures where TARGET != TARGET_ARCH do
# not work.  This defaults to the arch of the current machine.

ROBO_ARCH=`uname -p`

# Directory to poulate /app from
ROBO_APPDIR=""

# Directory to populate /cfg from
ROBO_CFGDIR=""

# Directory to populate /app from
NANO_APPDIR=""

# Directory to populate /data from
ROBO_DATADIR=""

# src.conf to use when building the image. Defaults to /dev/null for the sake
# of determinism.
SRCCONF=${SRCCONF:=/dev/null}
 
#######################################################################
#
# The functions which do the real work.
# Can be overridden from the config file(s)
#
#######################################################################

# run in the world chroot, errors fatal
CR()
{
	chroot ${ROBO_WORLDDIR} /bin/sh -exc "$*"
}

# run in the world chroot, errors not fatal
CR0()
{
	chroot ${ROBO_WORLDDIR} /bin/sh -c "$*" || true
}

robo_cleanup() (
	if [ $? -ne 0 ]; then
		echo "Error encountered.  Check for errors in last log file." 1>&2
	fi
	exit $?
)

clean_build() (
	pprint 2 "Clean and create object directory (${MAKEOBJDIRPREFIX})"

	if ! rm -xrf ${MAKEOBJDIRPREFIX}/ > /dev/null 2>&1 ; then
		chflags -R noschg ${MAKEOBJDIRPREFIX}/
		rm -xr ${MAKEOBJDIRPREFIX}/
	fi
	mkdir -p ${MAKEOBJDIRPREFIX}
	printenv > ${MAKEOBJDIRPREFIX}/_.env
)

make_conf_build() (
	pprint 2 "Construct build make.conf ($ROBO_MAKE_CONF_BUILD)"

	echo "${CONF_WORLD}" > ${ROBO_MAKE_CONF_BUILD}
	echo "${CONF_BUILD}" >> ${ROBO_MAKE_CONF_BUILD}
)

build_world() (
	pprint 2 "run buildworld"
	pprint 3 "log: ${MAKEOBJDIRPREFIX}/_.bw"

	cd ${ROBO_SRC}
	env TARGET_ARCH=${ROBO_ARCH} ${ROBO_PMAKE} \
		SRCCONF=${SRCCONF} \
		__MAKE_CONF=${ROBO_MAKE_CONF_BUILD} buildworld \
		> ${MAKEOBJDIRPREFIX}/_.bw 2>&1
)

build_kernel() (
	local extra

	pprint 2 "build kernel ($ROBO_KERNEL)"
	pprint 3 "log: ${MAKEOBJDIRPREFIX}/_.bk"

	(
	if [ -f ${ROBO_KERNEL} ] ; then
		kernconfdir_arg="KERNCONFDIR='$(realpath $(dirname ${ROBO_KERNEL}))'"
		kernconf=$(basename ${ROBO_KERNEL})
	else
		kernconf=${ROBO_KERNEL}
	fi

	cd ${ROBO_SRC};
	# unset these just in case to avoid compiler complaints
	# when cross-building
	unset TARGET_CPUTYPE
	# Note: We intentionally build all modules, not only the ones in
	# ROBO_MODULES so the built world can be reused by multiple images.
	eval "TARGET_ARCH=${ROBO_ARCH} ${ROBO_PMAKE} buildkernel \
		SRCCONF='${SRCCONF}' \
		__MAKE_CONF='${ROBO_MAKE_CONF_BUILD}' \
		${kernconfdir_arg} KERNCONF=${kernconf}"
	) > ${MAKEOBJDIRPREFIX}/_.bk 2>&1
)

clean_world() (
	if [ "${ROBO_OBJ}" != "${MAKEOBJDIRPREFIX}" ]; then
		pprint 2 "Clean and create object directory (${ROBO_OBJ})"
		if ! rm -rxf ${ROBO_OBJ}/ > /dev/null 2>&1 ; then
			chflags -R noschg ${ROBO_OBJ}
			rm -xr ${ROBO_OBJ}/
		fi
		mkdir -p ${ROBO_OBJ} ${ROBO_WORLDDIR}
		printenv > ${ROBO_OBJ}/_.env
	else
		pprint 2 "Clean and create world directory (${ROBO_WORLDDIR})"
		if ! rm -rxf ${ROBO_WORLDDIR}/ > /dev/null 2>&1 ; then
			chflags -R noschg ${ROBO_WORLDDIR}
			rm -rxf ${ROBO_WORLDDIR}/
		fi
		mkdir -p ${ROBO_WORLDDIR}
	fi
)

make_conf_install() (
	pprint 2 "Construct install make.conf ($ROBO_MAKE_CONF_INSTALL)"

	echo "${CONF_WORLD}" > ${ROBO_MAKE_CONF_INSTALL}
	echo "${CONF_INSTALL}" >> ${ROBO_MAKE_CONF_INSTALL}
)

install_world() (
	pprint 2 "installworld"
	pprint 3 "log: ${ROBO_OBJ}/_.iw"

	cd ${ROBO_SRC}
	env TARGET_ARCH=${ROBO_ARCH} \
	${ROBO_MAKE} SRCCONF=${SRCCONF} \
		__MAKE_CONF=${ROBO_MAKE_CONF_INSTALL} installworld \
		DESTDIR=${ROBO_WORLDDIR} \
		> ${ROBO_OBJ}/_.iw 2>&1
	chflags -R noschg ${ROBO_WORLDDIR}
)

install_etc() (

	pprint 2 "install /etc"
	pprint 3 "log: ${ROBO_OBJ}/_.etc"

	cd ${ROBO_SRC}
	env TARGET_ARCH=${ROBO_ARCH} \
	${ROBO_MAKE} SRCCONF=${SRCCONF} \
		__MAKE_CONF=${ROBO_MAKE_CONF_INSTALL} distribution \
		DESTDIR=${ROBO_WORLDDIR} \
		> ${ROBO_OBJ}/_.etc 2>&1
	# make.conf doesn't get created by default, but some ports need it
	# so they can spam it.
	cp /dev/null ${ROBO_WORLDDIR}/etc/make.conf
)

install_kernel() (
	local extra

	pprint 2 "install kernel ($ROBO_KERNEL)"
	pprint 3 "log: ${ROBO_OBJ}/_.ik"

	(
	if [ -f ${ROBO_KERNEL} ] ; then
		kernconfdir_arg="KERNCONFDIR='$(realpath $(dirname ${ROBO_KERNEL}))'"
		kernconf=$(basename ${ROBO_KERNEL})
	else
		kernconf=${ROBO_KERNEL}
	fi

	# Install all built modules if ROBO_MODULES=default,
	# else install only listed modules (none if ROBO_MODULES is empty).
	if [ "${ROBO_MODULES}" != "default" ]; then
		modules_override_arg="MODULES_OVERRIDE='${ROBO_MODULES}'"
	fi

	cd ${ROBO_SRC}
	eval "TARGET_ARCH=${ROBO_ARCH} ${ROBO_MAKE} installkernel \
		DESTDIR='${ROBO_WORLDDIR}' \
		SRCCONF='${SRCCONF}' \
		__MAKE_CONF='${ROBO_MAKE_CONF_INSTALL}' \
		${kernconfdir_arg} KERNCONF=${kernconf} \
		${modules_override_arg}"
	) > ${ROBO_OBJ}/_.ik 2>&1
)

run_customize() (

	pprint 2 "run customize scripts"
	for c in $ROBO_CUSTOMIZE
	do
		pprint 2 "customize \"$c\""
		pprint 3 "log: ${ROBO_OBJ}/_.cust.$c"
		pprint 4 "`type $c`"
		( set -x ; $c ) > ${ROBO_OBJ}/_.cust.$c 2>&1
	done
)

run_late_customize() (

	pprint 2 "run late customize scripts"
	for c in $ROBO_LATE_CUSTOMIZE
	do
		pprint 2 "late customize \"$c\""
		pprint 3 "log: ${ROBO_OBJ}/_.late_cust.$c"
		pprint 4 "`type $c`"
		( set -x ; $c ) > ${ROBO_OBJ}/_.late_cust.$c 2>&1
	done
)

setup_robobsd() (
	pprint 2 "configure robobsd setup"
	pprint 3 "log: ${ROBO_OBJ}/_.dl"

	(
	cd ${ROBO_WORLDDIR}

	# Move /usr/local/etc to /etc/local so that the /cfg stuff
	# can stomp on it.  Otherwise packages like ipsec-tools which
	# have hardcoded paths under ${prefix}/etc are not tweakable.
	if [ -d usr/local/etc ] ; then
		(
		mkdir -p etc/local
		cd usr/local/etc
		find . -print | cpio -dumpl ../../../etc/local
		cd ..
		rm -rf etc
		ln -s ../../etc/local etc
		)
	fi

	for d in var etc
	do
		# link /$d under /conf
		# we use hard links so we have them both places.
		# the files in /$d will be hidden by the mount.
		# XXX: configure /$d ramdisk size
		mkdir -p conf/base/$d conf/default/$d
		find $d -print | cpio -dumpl conf/base/
	done

	echo "$ROBO_RAM_ETCSIZE" > conf/base/etc/md_size
	echo "$ROBO_RAM_TMPVARSIZE" > conf/base/var/md_size

	# pick up config files from the special partition
	echo "mount -o ro /dev/${ROBO_DRIVE}s3" > conf/default/etc/remount

	# Put /tmp on the /var ramdisk (could be symlink already)
	test -d tmp && rmdir tmp || rm -f tmp
	ln -s var/tmp tmp

	) > ${ROBO_OBJ}/_.dl 2>&1
)

setup_robobsd_etc() (
	pprint 2 "configure robobsd /etc"

	(
	cd ${ROBO_WORLDDIR}

	# create diskless marker file
	touch etc/diskless

	# Make root filesystem R/O by default
	echo "root_rw_mount=NO" >> etc/defaults/rc.conf

	# save config file for scripts
	echo "ROBO_DRIVE=${ROBO_DRIVE}" > etc/robobsd.conf

	echo "/dev/${ROBO_DRIVE}s1a / ufs ro 10 1" > etc/fstab
	if [ $ROBO_APPSIZE -ne 0] ; then
		echo "/dev/${ROBO_DRIVE}s2 /app ufs ro 10 1" > etc/fstab
		mkdir -p app
	fi
	echo "/dev/${ROBO_DRIVE}s3 /cfg ufs rw,noauto 2 2" >> etc/fstab
	mkdir -p cfg
	if [ $ROBO_DATASIZE -ne 0] ; then
		echo "/dev/${ROBO_DRIVE}s4 /data ufs rw 2 3" > etc/fstab
		mkdir -p data
	fi
	)
)

prune_usr() (

	# Remove all empty directories in /usr 
	find ${ROBO_WORLDDIR}/usr -type d -depth -print |
		while read d
		do
			rmdir $d > /dev/null 2>&1 || true 
		done
)

newfs_part() (
	local dev mnt lbl
	dev=$1
	mnt=$2
	lbl=$3
	echo newfs ${ROBO_NEWFS} ${ROBO_LABEL:+-L${ROBO_LABEL}${lbl}} ${dev}
	newfs ${ROBO_NEWFS} ${ROBO_LABEL:+-L${ROBO_LABEL}${lbl}} ${dev}
	mount -o async ${dev} ${mnt}
)

# Convenient spot to work around any umount issues that your build environment
# hits by overriding this method.
robo_umount() (
	umount ${1}
)

populate_slice() (
	local dev dir mnt lbl
	dev=$1
	dir=$2
	mnt=$3
	lbl=$4
	echo "Creating ${dev} (mounting on ${mnt})"
	newfs_part ${dev} ${mnt} ${lbl}
	if [ -n "${dir}" -a -d "${dir}" ]; then
		echo "Populating ${lbl} from ${dir}"
		cd ${dir}
		find . -print | grep -Ev '/(CVS|\.svn|\.hg|\.git)' | cpio -dumpv ${mnt}
	fi
	df -i ${mnt}
	robo_umount ${mnt}
)

populate_app_slice() (
	populate_slice "$1" "$2" "$3" "$4"
)

populate_cfg_slice() (
	populate_slice "$1" "$2" "$3" "$4"
)

populate_data_slice() (
	populate_slice "$1" "$2" "$3" "$4"
)

create_i386_diskimage() (
	pprint 2 "build diskimage"
	pprint 3 "log: ${ROBO_OBJ}/_.di"

	(
	echo $ROBO_MEDIASIZE \
		$ROBO_SECTS $ROBO_HEADS \
		$ROBO_CODESIZE $ROBO_CONFSIZE $ROBO_APPSIZE $ROBO_DATASIZE |
	awk '
	{
		printf "# %s\n", $0

		# size of cylinder in sectors
		cs = $2 * $3

		# number of full cylinders on media
		cyl = int ($1 / cs)

		# output fdisk geometry spec, truncate cyls to 1023
		if (cyl <= 1023)
			print "g c" cyl " h" $3 " s" $2
		else
			print "g c" 1023 " h" $3 " s" $2

		if ($6 > 0) {
			# size of app partition in full cylinders
			asl = int (($6 + cs - 1) / cs)
		} else {
			asl = 0;
		}

		if ($7 > 0) { 
			# size of app partition in full cylinders
			asl = int (($7 + cs - 1) / cs)
		} else {
			asl = 0;
		}

		if ($8 > 0) { 
			# size of data partition in full cylinders
			dsl = int (($8 + cs - 1) / cs)
		} else {
			dsl = 0;
		}

		# size of config partition in full cylinders
		csl = int (($5 + cs - 1) / cs)

		if ($4 == 0) {
			# size of image partition(s) in full cylinders
			isl = int (cyl - dsl - asl - csl)
		} else {
			isl = int (($4 + cs - 1) / cs)
		}

		# First image partition start at second track
		print "p 1 165 " $2, isl * cs - $2
		c = isl * cs;

		# App partition (if any) starts at cylinder boundary.
		if ($6 > 0) {
			print "p 2 165 " c, asl * cs
			c += asl * cs
		}

		# Config partition starts at cylinder boundary.
		print "p 3 165 " c, csl * cs
		c += csl * cs

		# Data partition (if any) starts at cylinder boundary.
		if ($8 > 0) {
			print "p 4 165 " c, dsl * cs
		} else if ($8 < 0 && $1 > c) {
			print "p 4 165 " c, $1 - c
		} else if ($1 < c) {
			print "Disk space overcommitted by", \
			    c - $1, "sectors" > "/dev/stderr"
			exit 2
		}

		# Force slice 1 to be marked active. This is necessary
		# for booting the image from a USB device to work.
		print "a 1"
	}
	' > ${ROBO_OBJ}/_.fdisk

	IMG=${ROBO_DISKIMGDIR}/${ROBO_IMGNAME}
	MNT=${ROBO_OBJ}/_.mnt
	mkdir -p ${MNT}

	if [ "${ROBO_MD_BACKING}" = "swap" ] ; then
		MD=`mdconfig -a -t swap -s ${ROBO_MEDIASIZE} -x ${ROBO_SECTS} \
			-y ${ROBO_HEADS}`
	else
		echo "Creating md backing file..."
		rm -f ${IMG}
		dd if=/dev/zero of=${IMG} seek=${ROBO_MEDIASIZE} count=0
		MD=`mdconfig -a -t vnode -f ${IMG} -x ${ROBO_SECTS} \
			-y ${ROBO_HEADS}`
	fi

	trap "echo 'Running exit trap code' ; df -i ${MNT} ; robo_umount ${MNT} || true ; mdconfig -d -u $MD" 1 2 15 EXIT

	fdisk -i -f ${ROBO_OBJ}/_.fdisk ${MD}
	fdisk ${MD}
	# XXX: params
	# XXX: pick up cached boot* files, they may not be in image anymore.
	boot0cfg -B -b ${ROBO_WORLDDIR}/${ROBO_BOOTLOADER} ${ROBO_BOOT0CFG} ${MD}
	bsdlabel -w -B -b ${ROBO_WORLDDIR}/boot/boot ${MD}s1
	bsdlabel ${MD}s1

	# Create first image
	populate_slice /dev/${MD}s1a ${ROBO_WORLDDIR} ${MNT} "s1a"
	mount /dev/${MD}s1a ${MNT}
	echo "Generating mtree..."
	( cd ${MNT} && mtree -c ) > ${ROBO_OBJ}/_.mtree
	( cd ${MNT} && du -k ) > ${ROBO_OBJ}/_.du
	robo_umount ${MNT}

	if [ $ROBO_APPSIZE -ne 0] ; then
		populate_app_slice /dev/${MD}s2 "${ROBO_APPDIR}" ${MNT} "s2"
	fi

	# Create Config slice
	populate_cfg_slice /dev/${MD}s3 "${ROBO_CFGDIR}" ${MNT} "s3"

	# Create Data slice, if any.
	if [ $ROBO_DATASIZE -ne 0 ] ; then
		populate_data_slice /dev/${MD}s4 "${ROBO_DATADIR}" ${MNT} "s4"
	fi

	if [ "${ROBO_MD_BACKING}" = "swap" ] ; then
		if [ ${ROBO_IMAGE_MBRONLY} ]; then
			echo "Writing out _.disk.mbr..."
			dd if=/dev/${MD} of=${ROBO_DISKIMGDIR}/_.disk.mbr bs=512 count=1
		else
			echo "Writing out ${ROBO_IMGNAME}..."
			dd if=/dev/${MD} of=${IMG} bs=64k
		fi

		echo "Writing out ${ROBO_IMGNAME}..."
		dd conv=sparse if=/dev/${MD} of=${IMG} bs=64k
	fi

	if ${do_copyout_partition} ; then
		echo "Writing out _.disk.image..."
		dd conv=sparse if=/dev/${MD}s1 of=${ROBO_DISKIMGDIR}/_.disk.image bs=64k
	fi
	mdconfig -d -u $MD

	trap - 1 2 15
	trap robo_cleanup EXIT

	) > ${ROBO_OBJ}/_.di 2>&1
)

# i386 and amd64 are identical for disk images
create_amd64_diskimage() (
	create_i386_diskimage
)

last_orders() (
	# Redefine this function with any last orders you may have
	# after the build completed, for instance to copy the finished
	# image to a more convenient place:
	# cp ${ROBO_DISKIMGDIR}/_.disk.image /home/ftp/pub/robobsd.disk
	true
)

#######################################################################
#
# Optional convenience functions.
#
#######################################################################

#######################################################################
# Common Flash device geometries
#

FlashDevice() {
	if [ -d ${ROBO_TOOLS} ] ; then
		. ${ROBO_TOOLS}/FlashDevice.sub
	else
		. ${ROBO_SRC}/${ROBO_TOOLS}/FlashDevice.sub
	fi
	sub_FlashDevice $1 $2
}

#######################################################################
# USB device geometries
#
# Usage:
#	UsbDevice Generic 1000	# a generic flash key sold as having 1GB
#
# This function will set ROBO_MEDIASIZE, ROBO_HEADS and ROBO_SECTS for you.
#
# Note that the capacity of a flash key is usually advertised in MB or
# GB, *not* MiB/GiB. As such, the precise number of cylinders available
# for C/H/S geometry may vary depending on the actual flash geometry.
#
# The following generic device layouts are understood:
#  generic           An alias for generic-hdd.
#  generic-hdd       255H 63S/T xxxxC with no MBR restrictions.
#  generic-fdd       64H 32S/T xxxxC with no MBR restrictions.
#
# The generic-hdd device is preferred for flash devices larger than 1GB.
#

UsbDevice() {
	a1=`echo $1 | tr '[:upper:]' '[:lower:]'`
	case $a1 in
	generic-fdd)
		ROBO_HEADS=64
		ROBO_SECTS=32
		ROBO_MEDIASIZE=$(( $2 * 1000 * 1000 / 512 ))
		;;
	generic|generic-hdd)
		ROBO_HEADS=255
		ROBO_SECTS=63
		ROBO_MEDIASIZE=$(( $2 * 1000 * 1000 / 512 ))
		;;
	*)
		echo "Unknown USB flash device"
		exit 2
		;;
	esac
}

#######################################################################
# Setup serial console

cust_comconsole() (
	# Enable getty on console
	sed -i "" -e /tty[du]0/s/off/on/ ${ROBO_WORLDDIR}/etc/ttys

	# Disable getty on syscons devices
	sed -i "" -e '/^ttyv[0-8]/s/	on/	off/' ${ROBO_WORLDDIR}/etc/ttys

	# Tell loader to use serial console early.
	echo "${ROBO_BOOT2CFG}" > ${ROBO_WORLDDIR}/boot.config
)

#######################################################################
# Allow root login via ssh

cust_allow_ssh_root() (
	sed -i "" -e '/PermitRootLogin/s/.*/PermitRootLogin yes/' \
	    ${ROBO_WORLDDIR}/etc/ssh/sshd_config
)

#######################################################################
# Install the stuff under ./Files

cust_install_files() (
	cd ${ROBO_TOOLS}/Files
	find . -print | grep -Ev '/(CVS|\.svn|\.hg|\.git)' | cpio -Ldumpv ${ROBO_WORLDDIR}
)

#######################################################################
# Install packages from ${ROBO_PACKAGE_DIR}

cust_pkg() (

	# If the package directory doesn't exist, we're done.
	if [ ! -d ${ROBO_PACKAGE_DIR} ]; then
		echo "DONE 0 packages"
		return 0
	fi

	# Copy packages into chroot
	mkdir -p ${ROBO_WORLDDIR}/Pkg ${ROBO_WORLDDIR}/${ROBO_PKG_META_BASE}/pkg
	(
		cd ${ROBO_PACKAGE_DIR}
		find ${ROBO_PACKAGE_LIST} -print |
		    cpio -Ldumpv ${ROBO_WORLDDIR}/Pkg
	)

	# Count & report how many we have to install
	todo=`ls ${ROBO_WORLDDIR}/Pkg | wc -l`
	echo "=== TODO: $todo"
	ls ${ROBO_WORLDDIR}/Pkg
	echo "==="
	while true
	do
		# Record how many we have now
		have=`ls ${ROBO_WORLDDIR}/${ROBO_PKG_META_BASE}/pkg | wc -l`

		# Attempt to install more packages
		# ...but no more than 200 at a time due to pkg_add's internal
		# limitations.
		CR0 'ls Pkg/*tbz | xargs -n 200 env PKG_DBDIR='${ROBO_PKG_META_BASE}'/pkg pkg_add -v -F'

		# See what that got us
		now=`ls ${ROBO_WORLDDIR}/${ROBO_PKG_META_BASE}/pkg | wc -l`
		echo "=== NOW $now"
		ls ${ROBO_WORLDDIR}/${ROBO_PKG_META_BASE}/pkg
		echo "==="


		if [ $now -eq $todo ] ; then
			echo "DONE $now packages"
			break
		elif [ $now -eq $have ] ; then
			echo "FAILED: Nothing happened on this pass"
			exit 2
		fi
	done
	rm -rxf ${ROBO_WORLDDIR}/Pkg
)

cust_pkgng() (

	# If the package directory doesn't exist, we're done.
	if [ ! -d ${ROBO_PACKAGE_DIR} ]; then
		echo "DONE 0 packages"
		return 0
	fi

	# Find a pkg-* package
	for x in `find -s ${ROBO_PACKAGE_DIR} -iname 'pkg-*'`; do
		_ROBO_PKG_PACKAGE=`basename "$x"`
	done
	if [ -z "${_ROBO_PKG_PACKAGE}" -o ! -f "${ROBO_PACKAGE_DIR}/${_ROBO_PKG_PACKAGE}" ]; then
		echo "FAILED: need a pkg/ package for bootstrapping"
		exit 2
	fi

	# Copy packages into chroot
	mkdir -p ${ROBO_WORLDDIR}/Pkg
	(
		cd ${ROBO_PACKAGE_DIR}
		find ${ROBO_PACKAGE_LIST} -print |
		cpio -Ldumpv ${ROBO_WORLDDIR}/Pkg
	)

	#Bootstrap pkg
	CR env ASSUME_ALWAYS_YES=YES SIGNATURE_TYPE=none /usr/sbin/pkg add /Pkg/${_ROBO_PKG_PACKAGE}
	CR pkg -N >/dev/null 2>&1
	if [ "$?" -ne "0" ]; then
		echo "FAILED: pkg bootstrapping faied"
		exit 2
	fi
	rm -f ${ROBO_WORLDDIR}/Pkg/pkg-*

	# Count & report how many we have to install
	todo=`ls ${ROBO_WORLDDIR}/Pkg | /usr/bin/wc -l`
	todo=$(expr $todo + 1) # add one for pkg since it is installed already
	echo "=== TODO: $todo"
	ls ${ROBO_WORLDDIR}/Pkg
	echo "==="
	while true
	do
		# Record how many we have now
 		have=$(CR env ASSUME_ALWAYS_YES=YES /usr/sbin/pkg info | /usr/bin/wc -l)

		# Attempt to install more packages
		CR0 'ls 'Pkg/*txz' | xargs env ASSUME_ALWAYS_YES=YES /usr/sbin/pkg add'

		# See what that got us
 		now=$(CR env ASSUME_ALWAYS_YES=YES /usr/sbin/pkg info | /usr/bin/wc -l)
		echo "=== NOW $now"
		CR env ASSUME_ALWAYS_YES=YES /usr/sbin/pkg info
		echo "==="
		if [ $now -eq $todo ] ; then
			echo "DONE $now packages"
			break
		elif [ $now -eq $have ] ; then
			echo "FAILED: Nothing happened on this pass"
			exit 2
		fi
	done
	rm -rxf ${ROBO_WORLDDIR}/Pkg
)

#######################################################################
# Convenience function:
# 	Register all args as customize function.

customize_cmd() {
	ROBO_CUSTOMIZE="$ROBO_CUSTOMIZE $*"
}

#######################################################################
# Convenience function:
# 	Register all args as late customize function to run just before
#	image creation.

late_customize_cmd() {
	ROBO_LATE_CUSTOMIZE="$ROBO_LATE_CUSTOMIZE $*"
}

#######################################################################
#
# All set up to go...
#
#######################################################################

# Progress Print
#	Print $2 at level $1.
pprint() (
    if [ "$1" -le $PPLEVEL ]; then
	runtime=$(( `date +%s` - $ROBO_STARTTIME ))
	printf "%s %.${1}s %s\n" "`date -u -r $runtime +%H:%M:%S`" "#####" "$2" 1>&3
    fi
)

usage() {
	(
	echo "Usage: $0 [-bfiknqvw] [-c config_file]"
	echo "	-b	suppress builds (both kernel and world)"
	echo "	-f	suppress code slice extraction"
	echo "	-i	suppress disk image build"
	echo "	-k	suppress buildkernel"
	echo "	-n	add -DNO_CLEAN to buildworld, buildkernel, etc"
	echo "	-q	make output more quiet"
	echo "	-v	make output more verbose"
	echo "	-w	suppress buildworld"
	echo "	-c	specify config file"
	) 1>&2
	exit 2
}

#######################################################################
# Parse arguments

do_clean=true
do_kernel=true
do_world=true
do_image=true
do_copyout_partition=true

set +e
args=`getopt bc:fhiknqvw $*`
if [ $? -ne 0 ] ; then
	usage
	exit 2
fi
set -e

set -- $args
for i
do
	case "$i" 
	in
	-b)
		do_world=false
		do_kernel=false
		shift
		;;
	-k)
		do_kernel=false
		shift
		;;
	-c)
		# Make config file path available to the config file
		# itself so that it can access additional files relative
		# to its own location.
		ROBO_CONFIG=$2
		. "$2"
		shift
		shift
		;;
	-f)
		do_copyout_partition=false
		shift
		;;
	-h)
		usage
		;;
	-i)
		do_image=false
		shift
		;;
	-n)
		do_clean=false
		shift
		;;
	-q)
		PPLEVEL=$(($PPLEVEL - 1))
		shift
		;;
	-v)
		PPLEVEL=$(($PPLEVEL + 1))
		shift
		;;
	-w)
		do_world=false
		shift
		;;
	--)
		shift
		break
	esac
done

if [ $# -gt 0 ] ; then
	echo "$0: Extraneous arguments supplied"
	usage
fi

trap robo_cleanup EXIT

#######################################################################
# Setup and Export Internal variables
#
test -n "${ROBO_OBJ}" || ROBO_OBJ=/usr/obj/robobsd.${ROBO_NAME}/
test -n "${MAKEOBJDIRPREFIX}" || MAKEOBJDIRPREFIX=${ROBO_OBJ}
test -n "${ROBO_DISKIMGDIR}" || ROBO_DISKIMGDIR=${ROBO_OBJ}

ROBO_WORLDDIR=${ROBO_OBJ}/_.w
ROBO_MAKE_CONF_BUILD=${MAKEOBJDIRPREFIX}/make.conf.build
ROBO_MAKE_CONF_INSTALL=${ROBO_OBJ}/make.conf.install

if [ -d ${ROBO_TOOLS} ] ; then
	true
elif [ -d ${ROBO_SRC}/${ROBO_TOOLS} ] ; then
	ROBO_TOOLS=${ROBO_SRC}/${ROBO_TOOLS}
else
	echo "ROBO_TOOLS directory does not exist" 1>&2
	exit 1
fi

if $do_clean ; then
	true
else
	ROBO_MAKE="${ROBO_MAKE} -DNO_CLEAN"
	ROBO_PMAKE="${ROBO_PMAKE} -DNO_CLEAN"
fi

# Override user's ROBO_DRIVE if they specified a ROBO_LABEL
if [ ! -z "${ROBO_LABEL}" ]; then
	ROBO_DRIVE=ufs/${ROBO_LABEL}
fi

export MAKEOBJDIRPREFIX

export ROBO_ARCH
export ROBO_CODESIZE
export ROBO_CONFSIZE
export ROBO_CUSTOMIZE
export ROBO_DATASIZE
export ROBO_DRIVE
export ROBO_HEADS
export ROBO_IMGNAME
export ROBO_MAKE
export ROBO_MAKE_CONF_BUILD
export ROBO_MAKE_CONF_INSTALL
export ROBO_MEDIASIZE
export ROBO_NAME
export ROBO_NEWFS
export ROBO_OBJ
export ROBO_PMAKE
export ROBO_SECTS
export ROBO_SRC
export ROBO_TOOLS
export ROBO_WORLDDIR
export ROBO_BOOT0CFG
export ROBO_BOOTLOADER
export ROBO_LABEL

#######################################################################
# And then it is as simple as that...

# File descriptor 3 is used for logging output, see pprint
exec 3>&1

ROBO_STARTTIME=`date +%s`
pprint 1 "RoboBSD image ${ROBO_NAME} build starting"

if $do_world ; then
	if $do_clean ; then
		clean_build
	else
		pprint 2 "Using existing build tree (as instructed)"
	fi
	make_conf_build
	build_world
else
	pprint 2 "Skipping buildworld (as instructed)"
fi

if $do_kernel ; then
	if ! $do_world ; then
		make_conf_build
	fi
	build_kernel
else
	pprint 2 "Skipping buildkernel (as instructed)"
fi

clean_world
make_conf_install
install_world
install_etc
setup_robobsd_etc
install_kernel

run_customize
setup_robobsd
prune_usr
run_late_customize
if $do_image ; then
	create_${ROBO_ARCH}_diskimage
else
	pprint 2 "Skipping image build (as instructed)"
fi
last_orders

pprint 1 "RoboBSD image ${ROBO_NAME} completed"
