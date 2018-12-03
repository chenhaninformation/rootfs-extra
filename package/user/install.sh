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
echo ${username};
echo '1406';
echo '0731-12345678'
echo '13888888888'
echo 'empty') | useradd -m ${username}

if [ $? -ne 0 ]
then
	echo "'useradd' exit none zero!"
	exit 1
fi


# Add sudo privilege
echo "${username} ALL=(ALL) ALL" >> /etc/shdoers
if [ $? -ne 0 ]
then
	echo "'echo' exit none zero!"
	exit 1
fi

