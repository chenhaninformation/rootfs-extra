# Copyright (C) 2018-2019 Hunan ChenHan Information Technology Co., Ltd.
#
# SPDX-License-Identifier: GPL-3.0
#
# @author Ding Tao <miyatsu@qq.com>
# 
# @date 28th Nov, 2018
#
# @brief This Makefile is a good tools to generate Ubuntu rootfs by adding our
#	 own files.
#
# This Makefile is the top level Makefile of this project, and it will somehow
# include sub Makefile in this repo.
#

##############################################################################
#									     #
#			Global Variables Definition			     #
#									     #
##############################################################################

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

all: image

# This target will pack all files in $(ROOTFS_DIR) to a single image file
# to $(IMAGE_DIR)/image.tar.gz
image: overlay
	tar -cjvf ${IMAGE_DIR}/rootfs.tar.bz2 -C ${ROOTFS_DIR} .	\
		> /dev/null

# This target will add/deleate/alter file system's file after all files are
# copied to $(ROOTFS_DIR)
overlay: system
	@$(MAKE) -C overlay

# This target will download/compile a functional file system like
# Debian/Ubuntu, and copy all files to $(ROOTFS_DIR)
system:
	@$(MAKE) -C system

clean:
	-rm -rf $(CLEAN_TARGETS)

distclean: clean
	-rm -rf $(DISTCLEAN_TARGETS)

.PHONY: image overlay system clean distclean

##############################################################################
#									     #
#			Sub target definition				     #
#									     #
##############################################################################


_all: button

button:
	@$(MAKE) -C package/hw_button

download:
	@$(MAKE) -C package/iso

.PHONY: help install image clean distclean

help:
	@echo "Usage : make <target>"
	@echo "Where the target can be one of the following options"
	@echo "Help informations:"
	@echo "    help         - Show help message"
	@echo "Cleaning targets:"
	@echo "    clean        - Clean build file, but leave download files"
	@echo "    distclean    - Clean all build process generated files"

install:
	echo

IMAGE_DIR_NAME := image
IMAGE_DIR := ${BUILD_DIR}/${IMAGE_DIR_NAME}

_image:
	$(TOP_DIR)/scripts/gen_image.sh $(TOP_DIR) $(DL_DIR) $(BUILD_DIR) \
		$(IMAGE_DIR)


