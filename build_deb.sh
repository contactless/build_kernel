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

make_config() {
	cd ${DIR}/KERNEL
	if [[ -e ".config" ]]; then
		echo ".config already present"
		read -n 1 -p "Use $KERNEL_DEFCONFIG instead? (y/N) " yn
		echo
		if [[ "$yn" == "y" ]]; then
			make ARCH=arm $KERNEL_DEFCONFIG
		else
			echo "Using existing .config"
		fi
	else
		make ARCH=arm $KERNEL_DEFCONFIG
	fi
}

make_menuconfig () {
	cd ${DIR}/KERNEL
	make ARCH=arm menuconfig
	#~ cp -v .config ${DIR}/patches/defconfig
	cd ${DIR}/
}

make_deb_dtc() {
	local DTCVERSION="1.4.1+${DISTRO}${BUILDREV}"
	local DTCPKGNAME="device-tree-compiler_${DTCVERSION}_${DEBARCH}"
	local DTCTMPDIR=`mktemp -d`
	unset TARGET_ARCH	# it breaks dtc build for some strange reason

	[[ -e "${DIR}/KERNEL/scripts/dtc/Makefile.standalone" ]] || {
		echo "Not building device-tree-compiler for ${DEBARCH} due to absence of Makefile.standalone"
		return
	}

	pushd ${DIR}/KERNEL/scripts/dtc
	make -f Makefile.standalone clean &&
	make -f Makefile.standalone CC=${CROSS_COMPILE}gcc &&
	fakeroot make -f Makefile.standalone DESTDIR=$DTCTMPDIR/$DTCPKGNAME install
	ret=$?
	fakeroot make -f Makefile.standalone clean
	popd

	[[ $ret != 0 ]] && {
		echo "DTC build failed"
		return $ret
	}

	mkdir -p ${DTCTMPDIR}/${DTCPKGNAME}/DEBIAN
	cat > ${DTCTMPDIR}/${DTCPKGNAME}/DEBIAN/control <<EOF
Package: device-tree-compiler
Version: ${DTCVERSION}
Architecture: ${DEBARCH}
Maintainer: Alexey Ignatov <lexszero@gmail.com>
Depends: libc6 (>= 2.7)
Section: devel
Priority: optional
Description: Device Tree Compiler for Flat Device Trees with overlays support
EOF
	dpkg --build ${DTCTMPDIR}/${DTCPKGNAME}
	cp ${DTCTMPDIR}/${DTCPKGNAME}.deb ${DIR}/deploy/
	ln -s -f ${DTCPKGNAME}.deb ${DIR}/deploy/device-tree-compiler_${DEBARCH}.deb
	rm -rf ${DTCTMPDIR}
}

make_deb () {
	[[ -e "$(which depmod)" ]] || {
		echo "Need depmod to build modules correctly. Please install kmod package"
		exit 1
	}

	cd ${DIR}/KERNEL
	make -j${CORES} ARCH=arm KBUILD_DEBARCH=${DEBARCH}  zImage modules

	unset DTBS
	cat ${DIR}/KERNEL/arch/arm/Makefile | grep "dtbs:" >/dev/null 2>&1 && DTBS=1
	if [ "x${DTBS}" != "x" ] ; then
		echo "-----------------------------"
		echo "make -j${CORES} ARCH=arm dtbs"
		echo "-----------------------------"
		make -j${CORES} ARCH=arm dtbs
		ls arch/arm/boot/* | grep dtb >/dev/null 2>&1 || unset DTBS
	fi

	echo "-----------------------------"
	echo "make -j${CORES} ARCH=arm KBUILD_DEBARCH=${DEBARCH} KDEB_PKGVERSION=${DEB_PKGVERSION} bindeb-pkg"
	echo "-----------------------------"
	fakeroot make -j${CORES} ARCH=arm KBUILD_DEBARCH=${DEBARCH} KDEB_PKGVERSION=${DEB_PKGVERSION} bindeb-pkg
	mv ${DIR}/*.deb ${DIR}/deploy/


	KERNEL_UTS=$(cat ${DIR}/KERNEL/include/generated/utsrelease.h | awk '{print $3}' | sed 's/\"//g' )
	echo "kernel uts= $KERNEL_UTS"

	ln -s -f linux-image-${KERNEL_UTS}_${DEB_PKGVERSION}_${DEBARCH}.deb ${DIR}/deploy/linux-image_${DEBARCH}.deb
	ln -s -f linux-firmware-image-${KERNEL_UTS}_${DEB_PKGVERSION}_all.deb ${DIR}/deploy/linux-firmware-image_all.deb
	ln -s -f linux-headers-${KERNEL_UTS}_${DEB_PKGVERSION}_${DEBARCH}.deb ${DIR}/deploy/linux-headers_${DEBARCH}.deb
	ln -s -f linux-libc-dev_${DEB_PKGVERSION}_${DEBARCH}.deb ${DIR}/deploy/linux-libc-dev_${DEBARCH}.deb


	METATMPDIR=`mktemp -d`
	METAPKGNAME="linux-latest_${DEB_PKGVERSION}_${DEBARCH}"
	mkdir $METATMPDIR/${METAPKGNAME}
	mkdir $METATMPDIR/${METAPKGNAME}/DEBIAN
	cat <<EOF > "$METATMPDIR/${METAPKGNAME}/DEBIAN/control"
Package: linux-latest
Version: $DEB_PKGVERSION
Section: main
Priority: optional
Architecture: $DEBARCH
Depends: linux-image-${KERNEL_UTS} (>= $DEB_PKGVERSION), linux-firmware-image-${KERNEL_UTS} (>= $DEB_PKGVERSION), wb-configs (>= 1.04)
Installed-Size:
Maintainer: Evgeny Boger
Description: A metapackage for latest Linux kernel for Wiren Board
EOF

	dpkg --build ${METATMPDIR}/${METAPKGNAME}

	cp ${METATMPDIR}/${METAPKGNAME}.deb ${DIR}/deploy/
	ln -s -f ${METAPKGNAME}.deb ${DIR}/deploy/linux-latest_${DEBARCH}.deb
	rm -rf ${METATMPDIR}






	cd ${DIR}/
}

BUILDREV=`date -u +%Y%m%d%H%M%S`
DEB_PKGVERSION=${KERNEL_REL}+${DISTRO}${BUILDREV}

echo "Building kernel packages"
echo "Architecture: ${DEBARCH}"
echo "Package version: ${DEB_PKGVERSION}"

make_config
#~ make_menuconfig
make_deb
make_deb_dtc

echo "-----------------------------"
echo "Script Complete"
echo "$ export kernel_version=${KERNEL_UTS}]"
echo "-----------------------------"
