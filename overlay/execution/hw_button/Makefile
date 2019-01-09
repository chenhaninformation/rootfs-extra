# Copyright (C) 2018-2019 Hunan ChenHan Information Technology Co., Ltd.
#
# SPDX-License-Identifier: GPL-3.0
#
# @author Ding Tao <i@dingtao.org>
#
# @date 28th Nov, 2018
#
# @brief This Makefile is for button driver project

VPATH = ${ROOTFS_DIR}/usr/local/bin

hw_button: main.c -lpthread
	$(CC) -o $(ROOTFS_DIR)/usr/local/bin/hw_button main.c -lpthread

