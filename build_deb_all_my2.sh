#!/bin/bash -x

export PATH=/usr/local/go/bin:/home/ivan/wbdev/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export WBDEV_IMAGE=e7ce50351ace  #was af9c99e4bb61

export BUILDREV=`date -u +%Y%m%d%H%M%S`
. ./version.sh

for KERNEL_FLAVOUR in wb2; do  # wb6; do
	# get DEBARCH for current flavour
	setup_kernel_vars

	export WBDEV_TARGET=wheezy-${DEBARCH}
	KERNEL_FLAVOUR=${KERNEL_FLAVOUR} BUILDREV=${BUILDREV} ./build_deb_my2.sh
done

#for DEBARCH in armel armhf; do
#	export WBDEV_TARGET=wheezy-${DEBARCH}
#	wbdev user DEBARCH=${DEBARCH} BUILDREV=${BUILDREV} ./build_deb_dtc.sh
#done
