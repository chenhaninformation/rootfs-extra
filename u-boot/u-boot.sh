#!/bin/sh
#
# Copyright (C) 2019 Hunan ChenHan Information Technology Co., Ltd.
#
# SPDX-License-Identifier: GPL-3.0
#
# @author Ding Tao <i@dingtao.org>
#
# @date 14th Jan, 2019
#
# @brief This script will download the pre-build toolchain of aarch64 to dl
#	 directory and unpack it.
#
# Usage: ./u-boot.sh <build_dir> <toolchain_dir> <image_dir>
#	<build_dir>:		- Where to save temp file
#	<toolchain_dir>:	- Which toolchain we need to use
#	<image_dir>:		- Where to save final U-boot image

U_BOOT_URL=https://github.com/chenhaninformation/u-boot.git
U_BOOT_BRANCH=u-boot-2017.03-armada-17.10-ch-dev

ATF_URL=https://github.com/chenhaninformation/arm-trusted-firmware.git
ATF_BRANCH=atf-v1.3-armada-17.10-ch-dev

ATF_TOOL_URL=https://github.com/chenhaninformation/A3700-utils-marvell.git
ATF_TOOL_BRANCH=A3700_utils-armada-17.10-ch-dev

BUILD_LABEL_FILE=${BUILD_DIR}/u-boot-label.txt

BUILD_DIR=${1}
TOOLCHAIN_DIR=${2}
IMAGE_DIR=${3}

build_clone_u_boot () {
	# Make sure u-boot directory is empty
	if [ -e ${BUILD_DIR}/u-boot ]
	then
		rm -rf ${BUILD_DIR}/u-boot
	fi

	# Clone U-boot
	git clone --depth=10 --branch=${U_BOOT_BRANCH} ${U_BOOT_URL}	\
		${BUILD_DIR}/u-boot
	if [ $? -ne 0 ]
	then
		echo "git clone u-boot error!"
		exit 1
	fi

	# Save build info
	echo "----  U-boot  ----" >> ${BUILD_LABEL_FILE}
	echo "U-boot Repository: ${U_BOOT_URL}" >> ${BUILD_LABEL_FILE}
	echo "U-boot Branch: ${U_BOOT_BRANCH}" >> ${BUILD_LABEL_FILE}

	echo "U-boot commit: \c" >> ${BUILD_LABEL_FILE}

	# Retrieving U-boot HEAD commit hash id, and append to label file
	cat ${BUILD_DIR}/u-boot/.git/refs/heads/${U_BOOT_BRANCH}	\
		>> ${BUILD_LABEL_FILE}
	echo "" >> ${BUILD_LABEL_FILE}
}

build_clone_atf() {
	# Make sure atf directory is empty
	if [ -e ${BUILD_DIR}/atf ]
	then
		rm -rf ${BUILD_DIR}/atf
	fi

	# Clone ATF
	git clone --depth=10 --branch=${ATF_BRANCH} ${ATF_URL}	\
		${BUILD_DIR}/atf
	if [ $? -ne 0 ]
	then
		echo "git clone atf error!"
		exit 1
	fi

	# Save build info
	echo "----  ATF  ----" >> ${BUILD_LABEL_FILE}
	echo "ATF Repository: ${ATF_URL}" >> ${BUILD_LABEL_FILE}
	echo "ATF Branch: ${ATF_BRANCH}" >> ${BUILD_LABEL_FILE}

	echo "ATF commit: \c" >> ${BUILD_LABEL_FILE}

	# Retrieving ATF HEAD commit hash id, and append to label file
	cat ${BUILD_DIR}/atf/.git/refs/heads/${ATF_BRANCH}	\
		>> ${BUILD_LABEL_FILE}
	echo "" >> ${BUILD_LABEL_FILE}
}

build_clone_atf_tool() {
	# Make sure atf-tool directory is empty
	if [ -e ${BUILD_DIR}/atf-tool ]
	then
		rm -rf ${BUILD_DIR}/atf-tool
	fi

	# Clone ATF-TOOL
	git clone --depth=10 --branch=${ATF_TOOL_BRANCH} ${ATF_TOOL_URL} \
		${BUILD_DIR}/atf-tool
	if [ $? -ne 0 ]
	then
		echo "git clone atf-tool error!"
		exit 1
	fi

	# Save build info
	echo "----  ATF-TOOL  ----" >> ${BUILD_LABEL_FILE}
	echo "ATF-TOOL Repository: ${ATF_TOOL_URL}" >> ${BUILD_LABEL_FILE}
	echo "ATF-TOOL Branch: ${ATF_TOOL_BRANCH}" >> ${BUILD_LABEL_FILE}

	echo "ATF-TOOL commit: \c" >> ${BUILD_LABEL_FILE}

	# Retrieving ATF-TOOL HEAD commit hash id, and append to label file
	cat ${BUILD_DIR}/atf-tool/.git/refs/heads/${ATF_TOOL_BRANCH}	\
		>> ${BUILD_LABEL_FILE}
	echo "" >> ${BUILD_LABEL_FILE}

	mkdir -p ${BUILD_DIR}/atf-tool-backup
	cp -R ${BUILD_DIR}/atf-tool/* ${BUILD_DIR}/atf-tool-backup
}

build_export_rootfs_commit () {
	echo "----  Rootfs-extra  ----" >> ${BUILD_LABEL_FILE}
	echo "Rootfs-extra Branch: \c" >> ${BUILD_LABEL_FILE}
	git symbolic-ref --short -q HEAD >> ${BUILD_LABEL_FILE}

	echo "Rootfs-extra commit: \c" >> ${BUILD_LABEL_FILE}
	git rev-parse HEAD >> ${BUILD_LABEL_FILE}

	echo "Locally modfied files:" >> ${BUILD_LABEL_FILE}
	git status --porcelain >> ${BUILD_LABEL_FILE}

	echo "" >> ${BUILD_LABEL_FILE}
}

build_export_toolchain() {
	build_export_rootfs_commit

	export PATH=${TOOLCHAIN_DIR}/bin:${PATH}
	export CROSS_COMPILE=aarch64-linux-gnu-

	echo "GCC for arm64 information" >> ${BUILD_LABEL_FILE}
	aarch64-linux-gnu-gcc --version >> ${BUILD_LABEL_FILE}
	echo "" >> ${BUILD_LABEL_FILE}

	echo "GCC for arm32 information" >> ${BUILD_LABEL_FILE}
	arm-linux-gnueabi-gcc --version >> ${BUILD_LABEL_FILE}
	echo "" >> ${BUILD_LABEL_FILE}
}

build_u_boot () {
	cd ${BUILD_DIR}/u-boot
	make distclean

	aarch64-linux-gnu-gcc --version

	make espressobin_512m_spi_defconfig
	make -j8 DEVICE_TREE=armada-3720-espressobin
	if [ $? -ne 0 ]
	then
		echo "Build u-boot-512m-spi.bin failed!"
		exit 1
	fi
	cp u-boot.bin ${BUILD_DIR}/u-boot-512m-spi.bin

	make espressobin_512m_mmc_defconfig
	make -j8 DEVICE_TREE=armada-3720-espressobin
	if [ $? -ne 0 ]
	then
		echo "Build u-boot-512m-mmc.bin failed!"
		exit 1
	fi
	cp u-boot.bin ${BUILD_DIR}/u-boot-512m-mmc.bin

	make espressobin_1g_spi_defconfig
	make -j8 DEVICE_TREE=armada-3720-espressobin
	if [ $? -ne 0 ]
	then
		echo "Build u-boot-1g-spi.bin failed!"
		exit 1
	fi
	cp u-boot.bin ${BUILD_DIR}/u-boot-1g-spi.bin

	make espressobin_1g_mmc_defconfig
	make -j8 DEVICE_TREE=armada-3720-espressobin
	if [ $? -ne 0 ]
	then
		echo "Build u-boot-1g-mmc.bin failed!"
		exit 1
	fi
	cp u-boot.bin ${BUILD_DIR}/u-boot-1g-mmc.bin

	make espressobin_2g_spi_defconfig
	make -j8 DEVICE_TREE=armada-3720-espressobin
	if [ $? -ne 0 ]
	then
		echo "Build u-boot-2g-spi.bin failed!"
		exit 1
	fi
	cp u-boot.bin ${BUILD_DIR}/u-boot-2g-spi.bin

	make espressobin_2g_mmc_defconfig
	make -j8 DEVICE_TREE=armada-3720-espressobin
	if [ $? -ne 0 ]
	then
		echo "Build u-boot-2g-mmc.bin failed!"
		exit 1
	fi
	cp u-boot.bin ${BUILD_DIR}/u-boot-2g-mmc.bin

	make distclean
	cd -
}

build_atf_tool_clean () {
	rm -rf ${BUILD_DIR}/atf-tool/*
	cp -R ${BUILD_DIR}/atf-tool-backup/* ${BUILD_DIR}/atf-tool/
}

build_atf () {
	cd ${BUILD_DIR}/atf

	# Make sure image u-boot directory is empty
	if [ -e ${IMAGE_DIR}/u-boot ]
	then
		rm -rf ${IMAGE_DIR}/u-boot
	fi
	mkdir ${IMAGE_DIR}/u-boot

	aarch64-linux-gnu-gcc --version
	arm-linux-gnueabi-gcc --version

	mkdir -p ${IMAGE_DIR}/u-boot/ddr3/512m/1cs/spi
	mkdir -p ${IMAGE_DIR}/u-boot/ddr3/512m/1cs/mmc
	mkdir -p ${IMAGE_DIR}/u-boot/ddr3/1g/1cs/spi
	mkdir -p ${IMAGE_DIR}/u-boot/ddr3/1g/1cs/mmc
	mkdir -p ${IMAGE_DIR}/u-boot/ddr3/1g/2cs/spi
	mkdir -p ${IMAGE_DIR}/u-boot/ddr3/1g/2cs/mmc
	mkdir -p ${IMAGE_DIR}/u-boot/ddr3/2g/2cs/mmc
	mkdir -p ${IMAGE_DIR}/u-boot/ddr3/2g/2cs/spi
	# We ONLY build ddr3

	##### Build DDR3
	#### Build DDR3 512M
	### Build DDR3 512M 1CS
	## Build DDR3 512M 1CS SPI
	make distclean
	build_atf_tool_clean
	export BL33=${BUILD_DIR}/u-boot-512m-spi.bin
	make -j8 CLOCKSPRESET=CPU_1000_DDR_800			\
		DDR_TOPOLOGY=0					\
		USE_COHERENT_MEM=0				\
		BOOTDEV=SPINOR					\
		WTP=${BUILD_DIR}/atf-tool			\
		PLAT=a3700 all fip
	if [ $? -ne 0 ]
	then
		echo "Build ddr3-512m-1cs-spi failed!"
		exit 1
	fi
	cp build/a3700/release/flash-image.bin			\
		${IMAGE_DIR}/u-boot/ddr3/512m/1cs/spi
	cp -R build/a3700/release/uart-images			\
		${IMAGE_DIR}/u-boot/ddr3/512m/1cs/spi

	## Build DDR3 512M 1CS MMC
	make distclean
	build_atf_tool_clean
	export BL33=${BUILD_DIR}/u-boot-512m-mmc.bin
	make -j8 CLOCKSPRESET=CPU_1000_DDR_800			\
		DDR_TOPOLOGY=0					\
		USE_COHERENT_MEM=0				\
		BOOTDEV=EMMCNORM				\
		PARTNUM=1					\
		WTP=${BUILD_DIR}/atf-tool			\
		PLAT=a3700 all fip
	if [ $? -ne 0 ]
	then
		echo "Build ddr3-512m-1cs-mmc failed!"
		exit 1
	fi
	cp build/a3700/release/flash-image.bin			\
		${IMAGE_DIR}/u-boot/ddr3/512m/1cs/mmc
	cp -R build/a3700/release/uart-images			\
		${IMAGE_DIR}/u-boot/ddr3/512m/1cs/mmc

	#### Build DDR3 1G
	### Build DDR3 1G 1CS
	## Build DDR3 1G 1CS SPI
	make distclean
	build_atf_tool_clean
	export BL33=${BUILD_DIR}/u-boot-1g-spi.bin
	make -j8 CLOCKSPRESET=CPU_1000_DDR_800			\
		DDR_TOPOLOGY=4					\
		USE_COHERENT_MEM=0				\
		BOOTDEV=SPINOR					\
		WTP=${BUILD_DIR}/atf-tool			\
		PLAT=a3700 all fip
	if [ $? -ne 0 ]
	then
		echo "Build ddr3-1g-1cs-spi failed!"
		exit 1
	fi
	cp build/a3700/release/flash-image.bin			\
		${IMAGE_DIR}/u-boot/ddr3/1g/1cs/spi
	cp -R build/a3700/release/uart-images			\
		${IMAGE_DIR}/u-boot/ddr3/1g/1cs/spi

	## Build DDR3 1G 1CS MMC
	make distclean
	build_atf_tool_clean
	export BL33=${BUILD_DIR}/u-boot-1g-mmc.bin
	make -j8 CLOCKSPRESET=CPU_1000_DDR_800			\
		DDR_TOPOLOGY=4					\
		USE_COHERENT_MEM=0				\
		BOOTDEV=EMMCNORM				\
		PARTNUM=1					\
		WTP=${BUILD_DIR}/atf-tool			\
		PLAT=a3700 all fip
	if [ $? -ne 0 ]
	then
		echo "Build ddr3-1g-1cs-mmc failed!"
		exit 1
	fi
	cp build/a3700/release/flash-image.bin			\
		${IMAGE_DIR}/u-boot/ddr3/1g/1cs/mmc
	cp -R build/a3700/release/uart-images			\
		${IMAGE_DIR}/u-boot/ddr3/1g/1cs/mmc

	### Build DDR3 1G 2CS
	## Build DDR3 1G 2CS SPI
	make distclean
	build_atf_tool_clean
	export BL33=${BUILD_DIR}/u-boot-1g-spi.bin
	make -j8 CLOCKSPRESET=CPU_1000_DDR_800			\
		DDR_TOPOLOGY=2					\
		USE_COHERENT_MEM=0				\
		BOOTDEV=SPINOR					\
		WTP=${BUILD_DIR}/atf-tool			\
		PLAT=a3700 all fip
	if [ $? -ne 0 ]
	then
		echo "Build ddr3-1g-2cs-spi failed!"
		exit 1
	fi
	cp build/a3700/release/flash-image.bin			\
		${IMAGE_DIR}/u-boot/ddr3/1g/2cs/spi
	cp -R build/a3700/release/uart-images			\
		${IMAGE_DIR}/u-boot/ddr3/1g/2cs/spi

	## Build DDR3 1G 2CS MMC
	make distclean
	build_atf_tool_clean
	export BL33=${BUILD_DIR}/u-boot-1g-mmc.bin
	make -j8 CLOCKSPRESET=CPU_1000_DDR_800			\
		DDR_TOPOLOGY=2					\
		USE_COHERENT_MEM=0				\
		BOOTDEV=EMMCNORM				\
		PARTNUM=1					\
		WTP=${BUILD_DIR}/atf-tool			\
		PLAT=a3700 all fip
	if [ $? -ne 0 ]
	then
		echo "Build ddr3-1g-2cs-mmc failed!"
		exit 1
	fi
	cp build/a3700/release/flash-image.bin			\
		${IMAGE_DIR}/u-boot/ddr3/1g/2cs/mmc
	cp -R build/a3700/release/uart-images			\
		${IMAGE_DIR}/u-boot/ddr3/1g/2cs/mmc

	### Build DDR3 2G 2CS
	## Build DDR3 2G 2CS SPI
	make distclean
	build_atf_tool_clean
	export BL33=${BUILD_DIR}/u-boot-2g-spi.bin
	make -j8 CLOCKSPRESET=CPU_1000_DDR_800			\
		DDR_TOPOLOGY=7					\
		USE_COHERENT_MEM=0				\
		BOOTDEV=SPINOR					\
		WTP=${BUILD_DIR}/atf-tool			\
		PLAT=a3700 all fip
	if [ $? -ne 0 ]
	then
		echo "Build ddr3-2g-2cs-spi failed!"
		exit 1
	fi
	cp build/a3700/release/flash-image.bin			\
		${IMAGE_DIR}/u-boot/ddr3/2g/2cs/spi
	cp -R build/a3700/release/uart-images			\
		${IMAGE_DIR}/u-boot/ddr3/2g/2cs/spi

	## Build DDR3 2G 2CS MMC
	make distclean
	build_atf_tool_clean
	export BL33=${BUILD_DIR}/u-boot-2g-mmc.bin
	make -j8 CLOCKSPRESET=CPU_1000_DDR_800			\
		DDR_TOPOLOGY=7					\
		USE_COHERENT_MEM=0				\
		BOOTDEV=EMMCNORM				\
		PARTNUM=1					\
		WTP=${BUILD_DIR}/atf-tool			\
		PLAT=a3700 all fip
	if [ $? -ne 0 ]
	then
		echo "Build ddr3-2g-2cs-mmc failed!"
		exit 1
	fi
	cp build/a3700/release/flash-image.bin			\
		${IMAGE_DIR}/u-boot/ddr3/2g/2cs/mmc
	cp -R build/a3700/release/uart-images			\
		${IMAGE_DIR}/u-boot/ddr3/2g/2cs/mmc

	cd -
}

# Use label file to save build information, this echo will overwrite
# every thing in that file.
echo "Build Information" > ${BUILD_LABEL_FILE}
echo "-----------------" >> ${BUILD_LABEL_FILE}
echo "" >> ${BUILD_LABEL_FILE}

build_export_toolchain

build_clone_u_boot
build_clone_atf
build_clone_atf_tool


build_u_boot
build_atf

# Save build info to image directory
cp ${BUILD_LABEL_FILE} ${IMAGE_DIR}/u-boot/
