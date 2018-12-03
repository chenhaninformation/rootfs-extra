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

# Upgrade
echo y | apt upgrade
if [ $? -ne 0 ]
then
	echo "'apt upgrade' exit none zero!"
	exit 1
fi


# Install OpenSSH
apt install -y openssh-server
if [ $? -ne 0 ]
then
	echo "'apt install' exit none zero!"
	exit 1
fi



# Allow ssh password login
sed 's/#PasswordAuthentication yes/PasswordAuthentication yes/'	\
	/etc/ssh/sshd_config > /etc/ssh/sshd_config.tmp
if [ $? -ne 0 ]
then
	echo "'sed' exit none zero!"
	exit 1
fi

mv /etc/ssh/sshd_config.tmp /etc/ssh/sshd_config
if [ $? -ne 0 ]
then
	echo "'mv' exit none zero!"
	exit 1
fi

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
(echo ${password};
echo ${password};
echo '';
echo '';
echo '';
echo '';
echo '';
echo y)	|	\
	adduser ${username} --home /home/${username}	\
			    --shell /bin/bash
if [ $? -ne 0 ]
then
	echo "'adduser' exit none zero!"
	exit 1
fi

# Add sudo privilege
echo "${username} ALL=(ALL) ALL" >> /etc/shdoers
if [ $? -ne 0 ]
then
	echo "'echo' exit none zero!"
	exit 1
fi

# Back to host
exit 0

