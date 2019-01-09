#!/bin/sh
#
# Copyright (C) 2018-2019 Hunan ChenHan Information Technology Co., Ltd.
#
# SPDX-License-Identifier: GPL-3.0
#
# @author Ding Tao <i@dingtao.org>
#
# @date 8th Janu, 2019
#
# @brief This shell script will download the Ubuntu image to dl dir
#	 and unpack it, modify it to fit our need.
#
# This script will mount an iso file to a directory, and it will use -o
# options to do that, it require root privilege to run. Alter files in root
# file system also need root privilege. Make sure this script is running with
# root privilege either run by root or use sudo.
#
# Usage: ./ubuntu.sh <dl_dir> <build_dir> <rootfs_dir>
#	<dl_dir>      - Where to save downloaded Ubuntu iso file"
#	<build_dir>:  - Where to save temporary build output file"
#	<rootfs_dir>: - Where to save final root file system"
# WARNING: Any existed file in <rootfs_dir> will be removed"

DOWNLOAD_URL=http://cdimage.ubuntu.com/releases
RELEASE_VERSION=18.04
ISO_NAME=ubuntu-18.04.1-server-arm64.iso

ISO_URL=${DOWNLOAD_URL}/${RELEASE_VERSION}/release/${ISO_NAME}

DL_DIR=${1}
BUILD_DIR=${2}
ROOTFS_DIR=${3}

build_download() {
	wget -c --tries=5 -P ${DL_DIR} ${ISO_URL}
	if [ $? -ne 0 ]
	then
		echo "Download Error!"
		exit 1
	fi
}

build_extract() {
	# Make iso dir as mount point
	if [ -e ${BUILD_DIR}/iso ]
	then
		rm -rf ${BUILD_DIR}/iso
	fi
	mkdir -p ${BUILD_DIR}/iso

	# Mount Ubuntu iso image to mount point
	mount -o loop ${DL_DIR}/${ISO_NAME} ${BUILD_DIR}/iso
	if [ $? -ne 0 ]
	then
		echo "Mount Error!"
		exit 1
	fi

	# Clean rootfs dir and unpack squashfs to rootfs dir
	rm -rf ${ROOTFS_DIR}
	unsquashfs -d ${ROOTFS_DIR}	\
		${BUILD_DIR}/iso/install/filesystem.squashfs
	if [ $? -ne 0 ]
	then
		echo "Unsquashfs Error!"
		exit 1
	fi

	# Cleaned up
	umount ${BUILD_DIR}/iso
	rmdir ${BUILD_DIR}/iso
}

build_alter () {
	# Use sed to remove root password
	sed 'root/s/x//' ${ROOTFS_DIR}/etc/passwd >	\
		${ROOTFS_DIR}/etc/passwd.tmp
	mv ${ROOTFS_DIR}/etc/passwd.tmp ${ROOTFS_DIR}/etc/passwd

	# Add Marvell TTY device
	echo "ttyMV0" >> ${ROOTFS_DIR}/etc/securetty
}

print_usage() {
	echo "Usage: ./ubuntu.sh <dl_dir> <build_dir> <rootfs_dir>"
	echo "    <dl_dir>      - Where to save downloaded Ubuntu iso file"
	echo "    <build_dir>:  - Where to save temporary build output file"
	echo "    <rootfs_dir>: - Where to save final root file system"
	echo "WARNING: Any existed file in <rootfs_dir> will be removed"
}

check_args() {
	if [ $# -ne 3 ]
	then
		echo "Wrong argument!"
		echo ""
		print_usage
		exit 1
	fi

	if [ ! -d ${DL_DIR} ]
	then
		echo "Wrong argument, '${DL_DIR}' is not a directory!"
		exit 1
	fi

	if [ ! -d ${BUILD_DIR} ]
	then
		echo "Wrong argument, '${BUILD_DIR}' is not a directory!"
		exit 1
	fi

	if [ ! -d ${ROOTFS_DIR} ]
	then
		echo "Wrong argument, '${ROOTFS_DIR}' is not a directory!"
		exit 1
	fi
}

check_args $@

build_download
build_extract
build_alter

