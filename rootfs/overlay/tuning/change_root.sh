#!/bin/sh
#
# Copyright (C) 2018-2019 Hunan ChenHan Information Technology Co., Ltd.
#
# SPDX-License-Identifier: GPL-3.0
#
# @author Ding Tao <i@dingtao.org>
#
# @date 28th Nov, 2018
#
# @brief This shell script will use the build root file system as root file
#	 system, we do some modify here
#
# We copy all script need run within a board to "/tmp/chenhan/" so we can use
# qemu to emulate "real" board. We can not access shell exit state once we
# change root to target root file system, we use a single file
# "/tmp/chenhan/error" to indicate wether we have something wrong when running
# script in target file system. If this error file is exsited, we know
# something goes wrong and we should not trate this as a success build.

ROOTFS_DIR=${1}

build_tuning () {
	# Use qemu to emulate aarch64 on x86(_64) machine
	cp /usr/bin/qemu-aarch64-static ${ROOTFS_DIR}/usr/bin/

	# Copy all packages to root file system
	mkdir -p ${ROOTFS_DIR}/chenhan
	cp -R ./ ${ROOTFS_DIR}/chenhan/

	# Change to the new root file system
	chroot ${ROOTFS_DIR} /chenhan/do_tuning.sh
	if [ $? -ne 0 ]
	then
		echo "Chroot Error!"
		exit 1
	fi

	# Once chroot return, now already in host, so we can safily remove
	# some files
	echo "Successfuly back to host!"

	# Check state
	if [ -e ${ROOTFS_DIR}/chenhan/error ]
	then
		echo "Some thing goes wrong in chroot!"
		exit 1
	fi

	# Remove all package files
	rm -rf ${ROOTFS_DIR}/chenhan

	# Remove qemu emulator
	rm ${ROOTFS_DIR}/usr/bin/qemu-aarch64-static
}

print_usage () {
	echo "./change_root.sh <rootfs_dir>"
}

check_args() {
	if [ $# -ne 1 ]
	then
		echo "Wrong arguments!"
		print_usage
		exit 1
	fi

	if [ ! -d ${1} ]
	then
		echo "${1} is not direcotry!"
		exit 1
	fi
}

check_args $@
build_tuning

