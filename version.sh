#!/bin/sh


ARCH=$(uname -m)

if [ $(which nproc) ] ; then
	CORES=$(nproc)
else
	CORES=1
fi

#Kernel/Build
KERNEL_REL=4.9
KERNEL_TAG=${KERNEL_REL}

BRANCH="dev/v4.9.6"

BUILDREV=1.0
DISTRO=wb
LOCALVERSION=-wb

if [[ -z "$TARGET_ARCH" ]]; then
	echo "Warning: TARGET_ARCH is unset, assuming armel"
	TARGET_ARCH=armel
fi

case "$TARGET_ARCH" in
	armel)
		DEBARCH=armel
		KERNEL_DEFCONFIG=mxs_wirenboard_defconfig
		CROSS_COMPILE=arm-linux-gnueabi-
		;;
	armhf)
		DEBARCH=armhf
		KERNEL_DEFCONFIG=imx6_wirenboard_defconfig
		CROSS_COMPILE=arm-linux-gnueabihf-
		;;
esac

export CROSS_COMPILE LOCALVERSION
