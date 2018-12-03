#!/bin/sh

# Copyright (c) 2018 Hunan ChenHan Information Technology Co., Ltd.
#
# SPDX-License-Identifier: GPL-3.0
#
# @author Ding Tao <miyatsu@qq.com>
#
# @date 1st Dec, 2018


# Update
apt update
if [ $? -ne 0 ]
then
	echo "'apt update' exit none zero!"
	exit 1
fi

# Install make binutils gcc and other dependencies
apt install -y make binutils gcc
if [ $? -ne 0 ]
then
	echo "'apt install' exit none zero!"
	exit 1
fi

# Install package
for dir in `ls /root/package`
do
	cd /root/package/${dir}
	make
	if [ $? -ne 0 ]
	then
		echo "make failed in ${dir}"
	fi
done

# Uninstall useless software
apt remove -y make binutils gcc
if [ $? -ne 0 ]
then
	echo "'apt remove' exit none zero!"
	exit 1
fi

# Back to host
exit 0

