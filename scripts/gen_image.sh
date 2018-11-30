#!/bin/sh

# Copyright (c) 2018 Hunan ChenHan Information Technology Co., Ltd.
#
# SPDX-License-Identifier: GPL-3.0
#
# @author Ding Tao <miyatsu@qq.com>
#
# @date 28th Nov, 2018
#
# @brief This shell script will download the Ubuntu image to dl dir

DOWNLOAD_URL=http://cdimage.ubuntu.com/releases
RELEASE_VERSION=18.04
ISO_NAME=ubuntu-18.04.1-server-arm64.iso

DL_DIR=${1}
BUILD_DIR=${2}
OUTPUT_DIR=${3}
IMAGE_DIR=${4}

ISO_URL=${DOWNLOAD_URL}/${RELEASE_VERSION}/release/${ISO_NAME}

build_download() {
	wget -c --tries=5 -P ${DL_DIR} ${ISO_URL}
}

build_extract() {
	# Make iso dir as mount point
	if [ -e ${BUILD_DIR}/iso ]
	then
		rm -rf ${BUILD_DIR}/iso
	fi
	mkdir -p ${BUILD_DIR}/iso

	# Mount Ubuntu to mount point
	mount -o loop ${DL_DIR}/${ISO_NAME} ${BUILD_DIR}/iso

	# Remove rootfs dir for next process
	if [ -e ${BUILD_DIR}/rootfs ]
	then
		rm -rf ${BUILD_DIR}/rootfs
	fi

	# Unpack squashfs to new dir rootfs
	unsquashfs -d ${BUILD_DIR}/rootfs	\
		${BUILD_DIR}/iso/install/filesystem.squashfs

	# Cleaned up
	umount ${BUILD_DIR}/iso
	rmdir ${BUILD_DIR}/iso
}

build_alter() {
	# Use sed to remove root passwd
	sed '/root/s/x//' ${BUILD_DIR}/rootfs/etc/passwd >	\
		${BUILD_DIR}/rootfs/etc/passwd.tmp
	mv ${BUILD_DIR}/rootfs/etc/passwd.tmp ${BUILD_DIR}/rootfs/etc/passwd

	# Add Marvell TTY device
	echo "ttyMV0" >> ${BUILD_DIR}/rootfs/etc/securetty
}

build_append() {
	# Append all useful file generated using "make" into rootfs
	cp -R ${OUTPUT_DIR}/* ${BUILD_DIR}/rootfs
}

build_pack() {
	# Pack all stuff into one single tar file
	if [ -e ${IMAGE_DIR} ]
	then
		rm -rf ${IMAGE_DIR}
	fi

	mkdir -p ${IMAGE_DIR}

	tar -cjvf ${IMAGE_DIR}/rootfs.tar.bz2 -C ${BUILD_DIR}/rootfs .
}

build_download
build_extract
build_alter
build_append
build_pack

