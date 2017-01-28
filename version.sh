#!/bin/sh


ARCH=$(uname -m)

if [ $(which nproc) ] ; then
	CORES=$(nproc)
else
	CORES=1
fi

#Kernel/Build
KERNEL_REL=4.1
KERNEL_TAG=${KERNEL_REL}

BRANCH="dev/v4.1.15"

BUILDREV=1.0
DISTRO=wb

if [[ -z "$TARGET_ARCH" ]]; then
	echo "Warning: TARGET_ARCH is unset, assuming armel"
	TARGET_ARCH=armel
fi

case "$TARGET_ARCH" in
	armel)
		DEBARCH=armel
		KERNEL_DEFCONFIG=mxs_wirenboard_defconfig
		BUILD=imxv5-x0.1
		CC=arm-linux-gnueabi-
		;;
	armhf)
		DEBARCH=armhf
		KERNEL_DEFCONFIG=imx6_wirenboard_defconfig
		BUILD=imxv6-x0.1
		CC=arm-linux-gnueabihf-
		;;
esac
