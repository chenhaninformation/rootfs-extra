# Copyright (C) 2018-2019 Hunan ChenHan Information Technology Co., Ltd.
# 
# SPDX-License-Identifier: GPL-3.0
#
# @author Ding Tao <i@dingtao.org>
#
# @date 9th Jan, 2019
#
# @brief This Makefile is top level of file, it will copy all files in this
#	 directory to final root file system

TOOLCHAIN_DIR_NAME := toolchain

export TOOLCHAIN_DIR := $(shell mkdir -p				\
				$(BUILD_DIR)/$(TOOLCHAIN_DIR_NAME)	\
				&& cd $(BUILD_DIR)/$(TOOLCHAIN_DIR_NAME) \
				&& pwd)

all: u-boot

u-boot: toolchain
	./u-boot.sh $(BUILD_DIR) $(TOOLCHAIN_DIR) $(IMAGE_DIR)

toolchain:
	./toolchain.sh $(DL_DIR) $(TOOLCHAIN_DIR)

.PHONY: all u-boot toolchain

