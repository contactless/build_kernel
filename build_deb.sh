#!/bin/bash -e
#
# Copyright (c) 2009-2013 Robert Nelson <robertcnelson@gmail.com>
# Copyright (c) 2013-2015 Evgeny Boger <boger@contactless.ru>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

source version.sh

DIR=$PWD


mkdir -p ${DIR}/deploy/


make_menuconfig () {
	cd ${DIR}/KERNEL
	make ARCH=arm CROSS_COMPILE=${CC} menuconfig
	#~ cp -v .config ${DIR}/patches/defconfig
	cd ${DIR}/
}

make_deb () {
	cd ${DIR}/KERNEL
	make -j${CORES} ARCH=arm KBUILD_DEBARCH=${DEBARCH} LOCALVERSION=-${BUILD} CROSS_COMPILE=${CC}  zImage modules

	unset DTBS
	cat ${DIR}/KERNEL/arch/arm/Makefile | grep "dtbs:" >/dev/null 2>&1 && DTBS=1
	if [ "x${DTBS}" != "x" ] ; then
		echo "-----------------------------"
		echo "make -j${CORES} ARCH=arm LOCALVERSION=-${BUILD} CROSS_COMPILE=${CC} dtbs"
		echo "-----------------------------"
		make -j${CORES} ARCH=arm LOCALVERSION=-${BUILD} CROSS_COMPILE=${CC} dtbs
		ls arch/arm/boot/* | grep dtb >/dev/null 2>&1 || unset DTBS
	fi

	echo "-----------------------------"
	echo "make -j${CORES} ARCH=arm KBUILD_DEBARCH=${DEBARCH} LOCALVERSION=-${BUILD} CROSS_COMPILE=${CC} KDEB_PKGVERSION=${DEB_PKGVERSION} deb-pkg"
	echo "-----------------------------"
	fakeroot make -j${CORES} ARCH=arm KBUILD_DEBARCH=${DEBARCH} LOCALVERSION=-${BUILD} CROSS_COMPILE=${CC} KDEB_PKGVERSION=${DEB_PKGVERSION} deb-pkg
	mv ${DIR}/*.deb ${DIR}/deploy/


	KERNEL_UTS=$(cat ${DIR}/KERNEL/include/generated/utsrelease.h | awk '{print $3}' | sed 's/\"//g' )
	echo "kernel uts= $KERNEL_UTS"

	ln -s -f linux-image-${KERNEL_UTS}_${DEB_PKGVERSION}_armel.deb ${DIR}/deploy/linux-image_armel.deb
	ln -s -f linux-firmware-image-${KERNEL_UTS}_${DEB_PKGVERSION}_all.deb ${DIR}/deploy/linux-firmware-image_all.deb
	ln -s -f linux-headers-${KERNEL_UTS}_${DEB_PKGVERSION}_armel.deb ${DIR}/deploy/linux-headers_armel.deb
	ln -s -f linux-libc-dev_${DEB_PKGVERSION}_armel.deb ${DIR}/deploy/linux-libc-dev_armel.deb


	METATMPDIR=`mktemp -d`
	METAPKGNAME="linux-latest_${DEB_PKGVERSION}_all"
	mkdir $METATMPDIR/${METAPKGNAME}
	mkdir $METATMPDIR/${METAPKGNAME}/DEBIAN
	cat <<EOF > "$METATMPDIR/${METAPKGNAME}/DEBIAN/control"
Package: linux-latest
Version: $DEB_PKGVERSION
Section: main
Priority: optional
Architecture: all
Depends: linux-image-${KERNEL_UTS} (>= $DEB_PKGVERSION), linux-firmware-image-${KERNEL_UTS} (>= $DEB_PKGVERSION), wb-configs (>= 1.04)
Installed-Size:
Maintainer: Evgeny Boger
Description: A metapackage for latest Linux kernel for Wiren Board
EOF

	dpkg --build ${METATMPDIR}/${METAPKGNAME}

	cp ${METATMPDIR}/${METAPKGNAME}.deb ${DIR}/deploy/
	ln -s -f ${METAPKGNAME}.deb ${DIR}/deploy/linux-latest_all.deb
	rm -rf ${METATMPDIR}






	cd ${DIR}/
}

BUILDREV=`date -u +%Y%m%d%H%M%S`
DEB_PKGVERSION=${KERNEL_REL}-${BUILD}+${DISTRO}${BUILDREV}

#~ make_menuconfig
make_deb

echo "-----------------------------"
echo "Script Complete"
echo "$ export kernel_version=${KERNEL_UTS}]"
echo "-----------------------------"
