#!/bin/sh

ARCH=$(uname -m)

if [ $(which nproc) ] ; then
	CORES=$(nproc)
else
	CORES=1
fi

DIR=$PWD
SRCDIR=$DIR/KERNEL
PKGDIR=$DIR/deploy
mkdir -p "$PKGDIR"

BRANCH="dev/v4.1.15"

DISTRO=wb
KERNEL_REL=4.1

setup_kernel_vars() {
	case "$KERNEL_FLAVOUR" in
		wb2)
			DEBARCH=armel
			KERNEL_DEFCONFIG=mxs_wirenboard_defconfig
			FLAVOUR_DESC="Wiren Board 2-5"
			;;
		*)
			echo "Unsupported KERNEL_FLAVOUR, please specify one of: wb2, wb6"
			return 1
	esac
	LOCALVERSION=-${KERNEL_FLAVOUR}
	export DEBARCH KERNEL_DEFCONFIG FLAVOUR_DESC LOCALVERSION

	setup_deb_vars

	DEB_PKGVERSION=${KERNEL_REL}+${DISTRO}${BUILDREV}
	export DEB_PKGVERSION
}

setup_deb_vars() {
	case "$DEBARCH" in
		armel)
			CROSS_COMPILE=arm-linux-gnueabi-
			;;
		armhf)
			CROSS_COMPILE=arm-linux-gnueabihf-
			;;
		*)
			echo "Unsupported DEBARCH, please specify one of: armel, armhf"
			return 1
			;;
	esac
	[[ -z "$BUILDREV" ]] && BUILDREV=`date -u +%Y%m%d%H%M%S`
	export CROSS_COMPILE BUILDREV DEB_PKGVERSION
}
