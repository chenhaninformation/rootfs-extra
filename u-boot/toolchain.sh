#!/bin/sh
#
# Copyright (C) 2019 Hunan ChenHan Information Technology Co., Ltd.
#
# SPDX-License-Identifier: GPL-3.0
#
# @author Ding Tao <i@dingtao.org>
#
# @date 14th Jan, 2019
#
# @brief This script will download the pre-build toolchain of aarch64 to dl
#	 directory and unpack it.
#
# Usage: ./toolchain.sh <dl_dir> <toolchain_dir>
#	<dl_dir>:		- Where to save downloaded tar.xz file
#	<toolchain_dir>:	- Where to save unpacked files

URL=https://releases.linaro.org/components/toolchain/binaries
VERSION=5.5-2017.10
FILE_NAME=gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu

DL_URL=${URL}/${VERSION}/aarch64-linux-gnu/${FILE_NAME}.tar.xz

DL_DIR=${1}
TOOLCHAIN_DIR=${2}

build_download () {
	wget -c --tries=5 -P ${DL_DIR} ${DL_URL}
	if [ $? -ne 0 ]
	then
		echo "Download Error!"
		exit 1
	fi
}

build_extract () {
	rm -rf ${TOOLCHAIN_DIR}/*
	if [ $? -ne 0 ]
	then
		echo "Clean Toolchain Directory ${TOOLCHAIN} Error!"
		exit 1
	fi

	tar xvf ${DL_DIR}/${FILE_NAME}.tar.xz -C ${TOOLCHAIN_DIR}
	if [ $? -ne 0 ]
	then
		echo "Unpacking Toolchain Error!"
		exit 1
	fi

	# Origin tar.xz file have only one directory, let's move all binary
	# files up to the ${TOOLCHAIN_DIR} directory
	mv ${TOOLCHAIN_DIR}/${FILE_NAME}/* ${TOOLCHAIN_DIR}
	if [ $? -ne 0 ]
	then
		echo "Move File Error!"
		exit 1
	fi

	rmdir ${TOOLCHAIN_DIR}/${FILE_NAME}
	if [ $? -ne 0 ]
	then
		echo "Rmdir Error!"
		exit 1
	fi
}

print_usage () {
	echo "Usage: ./toolchain.sh <dl_dir> <toolchain_dir>"
	echo "	<dl_dir>:	- Where to save downloaded tar.xz file"
	echo "	<toolchain_dir>:	- Where to save unpacked files"
	echo "WARNING: Any existed file in <toolchain_dir> will be removed"
}

check_args () {
	if [ $# -ne 2 ]
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

	if [ ! -d ${TOOLCHAIN_DIR} ]
	then
		echo "Wrong argument, '${TOOLCHAIN_DIR}' is not a directory!"
		exit 1
	fi
}

check_args $@

build_download
build_extract

