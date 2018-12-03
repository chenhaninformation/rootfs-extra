#!/bin/sh

# Copyright (c) 2018 Hunan ChenHan Information Technology Co., Ltd.
#
# SPDX-License-Identifier: GPL-3.0
#
# @author Ding Tao <miyatsu@qq.com>
#
# @date 1st Dec, 2018

username="chinfo"
password="chinfo"

# Update
apt update

if [ $? -ne 0 ]
then
	echo "'apt update' exit none zero!"
	exit 1
fi

# Install OpenSSH
apt install -y openssh-server

# Allow password login
sed 's/#PasswordAuthentication yes/PasswordAuthentication yes/'	\
	/etc/ssh/sshd_config > /etc/ssh/sshd_config.tmp
mv /etc/ssh/sshd_config.tmp /etc/ssh/sshd_config

# Add user with ${username} and ${password}
#
# No.1 echo: user password
# No.2 echo: user password retype
# No.3 echo: Full Name []:
# No.4 echo: Room Number []:
# No.5 echo: Work Phone []:
# No.6 echo: Home Phone []:
# No.7 echo: Other []:
# No.8 echo: Is the information correct? [Y/n]
(echo ${password};	\
echo ${password};	\
echo '';		\
echo '';		\
echo '';		\
echo '';		\
echo '';		\
echo y) |		\
	adduser ${username} --home /home/${username}	\
			    --shell /bin/bash

# Add sudo privilege
echo "${username} ALL=(ALL) ALL" >> /etc/shdoers

# Back to host
exit

