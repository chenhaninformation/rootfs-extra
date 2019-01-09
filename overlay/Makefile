# Copyright (C) 2018-2019 Hunan ChenHan Information Technology Co., Ltd.
# 
# SPDX-License-Identifier: GPL-3.0
#
# @author Ding Tao <i@dingtao.org>
#
# @date 9th Jan, 2019
#
# @brief This Makefile is top level of overlay, it will run make in sub
# 	 directories.

# Make sub directories knows whre to save temporary file and final root file
# system files
export BUILD_DIR
export ROOTFS_DIR

all: tuning

tuning: execution
	$(MAKE) -C tuning

execution: file
	$(MAKE) -C execution

file: 
	$(MAKE) -C file

.PHONY: tuning execution file
