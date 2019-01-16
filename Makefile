# Copyright (C) 2018-2019 Hunan ChenHan Information Technology Co., Ltd.
#
# SPDX-License-Identifier: GPL-3.0
#
# @author Ding Tao <i@dingtao.org>
# 
# @date 28th Nov, 2018
#
# @brief This Makefile is a good tools to generate Ubuntu rootfs by adding our
#	 own files.
#
# This Makefile is the top level Makefile of this project, and it will somehow
# include sub Makefile in this repo.

# Define sub directory name of build and download
BUILD_DIR_NAME		:= build
DL_DIR_NAME		:= dl
ROOTFS_DIR_NAME		:= $(BUILD_DIR_NAME)/rootfs
IMAGE_DIR_NAME		:= $(BUILD_DIR_NAME)/image

# Top directory, build directory and download directory
export TOP_DIR		:= $(shell pwd)
export BUILD_DIR	:= $(shell mkdir -p				\
				   $(TOP_DIR)/$(BUILD_DIR_NAME)		\
				   && cd $(TOP_DIR)/$(BUILD_DIR_NAME)	\
				   && pwd)
export DL_DIR		:= $(shell mkdir -p				\
				   $(TOP_DIR)/$(DL_DIR_NAME)		\
				   && cd $(TOP_DIR)/$(DL_DIR_NAME)	\
				   && pwd)

# Sub directory within build directory
export ROOTFS_DIR	:= $(shell mkdir -p				\
				   $(TOP_DIR)/$(ROOTFS_DIR_NAME)	\
				   && cd $(TOP_DIR)/$(ROOTFS_DIR_NAME)	\
				   && pwd)
export IMAGE_DIR	:= $(shell mkdir -p				\
				   $(TOP_DIR)/$(IMAGE_DIR_NAME)		\
				   && cd $(TOP_DIR)/$(IMAGE_DIR_NAME)	\
				   && pwd)

# Clean targets
export CLEAN_TARGETS		:= $(BUILD_DIR)
export DISTCLEAN_TARGETS	:= $(DL_DIR)

all: rootfs u-boot

### Rootfs related target

# This target will pack all files in $(ROOTFS_DIR) to a single image file
# to $(IMAGE_DIR)/image.tar.gz
rootfs: overlay
	tar -cjvf ${IMAGE_DIR}/rootfs.tar.bz2 -C ${ROOTFS_DIR} .	\
		> /dev/null

# This target will add/deleate/alter file system's file after all files are
# copied to $(ROOTFS_DIR)
overlay: system
	@$(MAKE) -C rootfs/overlay

# This target will download/compile a functional file system like
# Debian/Ubuntu, and copy all files to $(ROOTFS_DIR)
system:
	@$(MAKE) -C rootfs/system

### U-boot related target

u-boot:
	@$(MAKE) -C u-boot

clean:
	-rm -rf $(CLEAN_TARGETS)

distclean: clean
	-rm -rf $(DISTCLEAN_TARGETS)

.PHONY: rootfs overlay system u-boot clean distclean

