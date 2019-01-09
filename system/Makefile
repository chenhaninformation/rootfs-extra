# Copyright (C) 2018-2019 Hunan ChenHan Information Technology Co., Ltd.
#
# SPDX-License-Identifier: GPL-3.0
#
# @author Ding Tao <i@dingtao.org>
#
# @date 8th Janu, 2019
#
# @brief This Makefile will generate root file system files into a empty
# 	 directory.

CONFIG_SYSTEM_UBUNTU = y

ifeq ($(CONFIG_SYSTEM_UBUNTU),y)
	SYSTEM=ubuntu
endif

ifeq ($(CONFIG_SYSTEM_DEBIAN),y)
	SYSTEM=debian
endif

.PHONY: system
system:
	./$(SYSTEM).sh $(DL_DIR) $(BUILD_DIR) $(ROOTFS_DIR)

