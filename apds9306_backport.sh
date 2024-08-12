#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# 
# Helper script to build IIO GTS helper module and APDS9306 module
#
# Copyright (C) 2024 Subhajit Ghosh <subhajit.ghosh@tweaklogic.com>

show_help()
{
	echo "./apds9306_backport.sh build <kernel_build_dir_path>"
	echo "./apds9306_backport.sh clean <kernel_build_dir_path>"
}

if [ "x${1}" != "xbuild" ] && [ "x${1}" != "xclean" ]; then
	show_help
	exit 1
fi

if [ "x${2}" == "x" ]; then
	echo "Please enter kernel build directory"
	show_help
	exit 1
fi

KERNEL_BUILD_DIR=${2}

CROSS=$(printenv | grep CROSS_COMPILE)
if [ "x${CROSS}" == "x" ]; then
	echo "No cross toolchain detected"
	echo "source <path to your toolchain setup file>"
	show_help
	exit 2
fi

if [ "x${1}" == "xclean" ]; then
	echo "Cleaning..."
	make KDIR=${KERNEL_BUILD_DIR} BUILD=iio_gts clean
	rm -rf output
	exit 0
fi

rm -rf output
mkdir -p output

pushd ${KERNEL_BUILD_DIR} > /dev/null
KERVER=$(make kernelversion)
popd > /dev/null
KERMAJ=$(echo $KERVER | cut -d. -f1)
KERMIN=$(echo $KERVER | cut -d. -f2)
if [ "x${KERMAJ}" == "x" ] || [ "x${KERMIN}" == "x" ]; then
	echo "Could not find kernel version"
	exit 4
fi

if [ $KERMAJ -ge 6 ] && [ $KERMIN -ge 4 ]; then
	echo "Building only apds9606.ko"
	make KDIR=${KERNEL_BUILD_DIR}
else
	echo "Building iio_gts.ko and apds9606.ko"
	make KDIR=${KERNEL_BUILD_DIR} BUILD=iio_gts
fi

echo "Copying driver(s) to output directory..."
find . -name "*.ko" -exec cp "{}" output \;

