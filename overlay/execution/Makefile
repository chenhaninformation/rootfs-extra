# Copyright (C) 2018-2019 Hunan ChenHan Information Technology Co., Ltd.
#
# SPDX-License-Identifier: GPL-3.0
#
# @author Ding Tao <i@dingtao.org>
#
# @date 9th Jan, 2019
#
# @brief This Makefile is top level of excutable project

# Make sub Makefile knows about how where to save bin file
export ROOTFS_DIR

# Default use aarch64-linux-gnu-gcc compiler
export CROSS_COMPILE ?= aarch64-linux-gnu-
export CC := $(CROSS_COMPILE)gcc


all: hw_button

hw_button:
	$(MAKE) -C hw_button

.PHONY: hw_button
