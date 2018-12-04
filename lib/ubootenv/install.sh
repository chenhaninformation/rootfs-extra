#!/bin/sh

# Copyright (c) 2018 Hunan ChenHan Information Technology Co., Ltd.
#
# SPDX-License-Identifier: GPL-3.0
#
# @author Ding Tao <miyatsu@qq.com>
#
# @date 3rd Dec, 2018
#
# @brief This shell script will install openssh via apt and modify some
#	 configurations like allow password login.

BUILD_DIR=$1
OUTPUT_DIR=$2

# Get the u-boot code
if [ -e ${BUILD_DIR}/u-boot ]
then
	rm -rf ${BUILD_DIR}/u-boot
fi
git clone --depth=50 -b u-boot-2018.03-armada-18.09 \
	https://github.com/MarvellEmbeddedProcessors/u-boot-marvell \
	${BUILD_DIR}/u-boot
if [ $? -ne 0 ]
then
	echo "'git clone' exit none zero!"
	exit 1
fi

export CROSS_COMPILE=aarch64-linux-gnu-
export ARCH=arm64

# Cd to source code and compile it
cd ${BUILD_DIR}/u-boot
make mvebu_espressobin-88f3720_defconfig
make env

# Move shared library to rootfs
if [ ! -e ${BUILD_DIR}/u-boot/tools/env/lib.a ]
then
	echo "'make' exit none zero!"
	exit 1
fi

if [ ! -d ${OUTPUT_DIR}/usr/local/lib ]
then
	mkdir -p ${OUTPUT_DIR}/usr/local/lib
fi
cp ${BUILD_DIR}/u-boot/tools/env/lib.a	\
	${OUTPUT_DIR}/usr/local/lib/libubootenv.a

