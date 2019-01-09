#!/bin/sh

# Copyright (c) 2018 Hunan ChenHan Information Technology Co., Ltd.
#
# SPDX-License-Identifier: GPL-3.0
#
# @author Ding Tao <miyatsu@qq.com>
#
# @date 3rd Dec, 2018
#
# @brief This shell script will add a user into the rootfs


username=chinfo
password=chinfo

# Add user
useradd -m -s /bin/bash ${username}
if [ $? -ne 0 ]
then
	echo "'useradd' exit none zero!"
	exit 1
fi

# Change password
echo "${username}:${password}" | chpasswd
if [ $? -ne 0 ]
then
	echo "'chpasswd' exit none zero!"
	exit 1
fi

# Add sudo privilege
echo "${username} ALL=(ALL) ALL" >> /etc/shdoers
if [ $? -ne 0 ]
then
	echo "'echo' exit none zero!"
	exit 1
fi

