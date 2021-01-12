#!/bin/bash -x

#Run build_deb_all without wbdev.

export BUILDREV=`date -u +%Y%m%d%H%M%S`
. ./version.sh

for KERNEL_FLAVOUR in wb6; do  #wb2 wb6
	# get DEBARCH for current flavour
	setup_kernel_vars

	export WBDEV_TARGET=wheezy-${DEBARCH}
	KERNEL_FLAVOUR=${KERNEL_FLAVOUR} BUILDREV=${BUILDREV} ./build_deb.sh
done

#DTC is no longer built.
#for DEBARCH in armel armhf; do
#	export WBDEV_TARGET=stretch-${DEBARCH}
#	DEBARCH=${DEBARCH} BUILDREV=${BUILDREV} ./build_deb_dtc.sh
#done
