#!/bin/bash -x

#Temp. use test docker image
export WBDEV_IMAGE=contactless/devenv:test

#Under 'wbdev user' we should remove user path that comes from ~/.profile, because it can break the build.
export PATH=/usr/local/go/bin:/home/ivan/wbdev/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
#umask set in ~/.profile can break the build (debian/control file umask must be default)
umask 022

export BUILDREV=`date -u +%Y%m%d%H%M%S`
. ./version.sh

for KERNEL_FLAVOUR in wb2 wb6; do
	# get DEBARCH for current flavour
	setup_kernel_vars

	export WBDEV_TARGET=wheezy-${DEBARCH}
	wbdev user KERNEL_FLAVOUR=${KERNEL_FLAVOUR} BUILDREV=${BUILDREV} ./build_deb.sh
done

#device-tree-compiler теперь не строится с ядром, а идет пакетом из репо Debian.
#for DEBARCH in armel armhf; do
#	export WBDEV_TARGET=wheezy-${DEBARCH}
#	wbdev user DEBARCH=${DEBARCH} BUILDREV=${BUILDREV} ./build_deb_dtc.sh
#done
