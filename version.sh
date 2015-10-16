#!/bin/sh

CC=arm-linux-gnueabi-

ARCH=$(uname -m)

if [ $(which nproc) ] ; then
	CORES=$(nproc)
else
	CORES=1
fi

#Kernel/Build
KERNEL_REL=3.19
KERNEL_TAG=${KERNEL_REL}
BUILD=imxv5-x0.1

BRANCH="v3.19.x-imxv5"

BUILDREV=1.0
DISTRO=wb
DEBARCH=armel
