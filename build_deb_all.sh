#!/bin/bash -x

#Temp. use test docker image
export WBDEV_IMAGE=contactless/devenv:test

export BUILDREV=`date -u +%Y%m%d%H%M%S`
. ./version.sh

for KERNEL_FLAVOUR in wb2 wb6; do
	# get DEBARCH for current flavour
	setup_kernel_vars

	export WBDEV_TARGET=wheezy-${DEBARCH}
	wbdev user KERNEL_FLAVOUR=${KERNEL_FLAVOUR} BUILDREV=${BUILDREV} ./build_deb.sh
done

for DEBARCH in armel armhf; do
	export WBDEV_TARGET=wheezy-${DEBARCH}
	wbdev user DEBARCH=${DEBARCH} BUILDREV=${BUILDREV} ./build_deb_dtc.sh
done
