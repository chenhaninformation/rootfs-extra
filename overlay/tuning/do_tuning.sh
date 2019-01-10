#!/bin/sh
#
# Copyright (C) 2018-2019 Hunan ChenHan Information Technology Co., Ltd.
#
# SPDX-License-Identifier: GPL-3.0
#
# @author Ding Tao <i@dingtao.org>
#
# @date 9th Jan, 2019
#
# @brief This shell script will run in target file system, to install our own
#	 packages
#
# We can not pass exit state back to host file system, so we touch a file
# "/chenhan/error" to mark we have error happened. Host file system can access
# this file using ${ROOTFS_DIR}/chenhan/error to knows about it.

# Update
apt update
if [ $? -ne 0 ]
then
	echo "'apt update' exit none zero!"
	# Touch error file to inform host, we have error here
	touch /chenhan/error
	exit 1
fi

# Install package
for dir in `ls /chenhan`
do
	# Current file is not directory, skip it
	if [ ! -d /chenhan/${dir} ]
	then
		continue
	fi

	# Run package specific install.sh
	/chenhan/${dir}/install.sh

	# Check statue
	if [ $? -ne 0 ]
	then
		echo "Install ${dir} failed!"
		# Touch error file to inform host, we have error here
		touch /chenhan/error
		exit 1
	fi
done

# Back to host
exit 0
