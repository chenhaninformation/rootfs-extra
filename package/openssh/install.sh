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


sudo apt install -y openssh-server

# Allow ssh password login
sudo sed 's/#PasswordAuthentication yes/PasswordAuthentication yes/'	\
	/etc/ssh/sshd_config > /etc/ssh/sshd_config.tmp
if [ $? -ne 0 ]
then
	echo "'sed' exit none zero!"
	exit 1
fi

# Use the seded config file
sudo mv /etc/ssh/sshd_config.tmp /etc/ssh/sshd_config
if [ $? -ne 0 ]
then
	echo "'mv' exit none zero!"
	exit 1
fi

