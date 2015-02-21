#!/bin/sh -e
#
# Copyright (c) 2009-2013 Robert Nelson <robertcnelson@gmail.com>
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

DIR=$PWD


mkdir -p ${DIR}/deploy/

patch_kernel () {
	cd ${DIR}/KERNEL

	export DIR GIT_OPTS
	/bin/sh -e ${DIR}/patch.sh || { git add . ; exit 1 ; }

	if [ ! "${RUN_BISECT}" ] ; then
		git add --all
		git commit --allow-empty -a -m "${KERNEL_TAG}-${BUILD} patchset"
	fi

	cd ${DIR}/
}

pull_dev () {
	cd ${DIR}/KERNEL
	export DIR GIT_OPTS
	echo "pulling dev repo"
	git pull dev

	cd ${DIR}/
}

copy_defconfig () {
	cd ${DIR}/KERNEL/
	make ARCH=arm CROSS_COMPILE=${CC} distclean
	make ARCH=arm CROSS_COMPILE=${CC} ${config}
	cp -v .config ${DIR}/patches/ref_${config}
	cp -v ${DIR}/patches/defconfig .config
	cd ${DIR}/
}

make_menuconfig () {
	cd ${DIR}/KERNEL/
	make ARCH=arm CROSS_COMPILE=${CC} menuconfig
	cp -v .config ${DIR}/patches/defconfig
	cd ${DIR}/
}

make_deb () {
	cd ${DIR}/KERNEL/
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
	ln -s -f linux-firmware-image-${KERNEL_UTS}_${DEB_PKGVERSION}_armel.deb ${DIR}/deploy/linux-firmware-image_armel.deb
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
	ln -s -f ${DIR}/deploy/${METAPKGNAME}.deb ${DIR}/deploy/linux-latest_all.deb
	rm -rf ${METATMPDIR}






	cd ${DIR}/
}

make_pkg () {
	cd ${DIR}/KERNEL/

	deployfile="-${pkg}.tar.gz"
	if [ -f "${DIR}/deploy/${KERNEL_UTS}${deployfile}" ] ; then
		rm -rf "${DIR}/deploy/${KERNEL_UTS}${deployfile}" || true
	fi

	if [ -d ${DIR}/deploy/tmp ] ; then
		rm -rf ${DIR}/deploy/tmp || true
	fi
	mkdir -p ${DIR}/deploy/tmp

	echo "-----------------------------"
	echo "Building ${pkg} archive..."

	case "${pkg}" in
	modules)
		make -s ARCH=arm CROSS_COMPILE=${CC} modules_install INSTALL_MOD_PATH=${DIR}/deploy/tmp
		;;
	firmware)
		make -s ARCH=arm CROSS_COMPILE=${CC} firmware_install INSTALL_FW_PATH=${DIR}/deploy/tmp
		;;
	dtbs)
		find ./arch/arm/boot/ -iname "*.dtb" -exec cp -v '{}' ${DIR}/deploy/tmp/ \;
		;;
	esac

	echo "Compressing ${KERNEL_UTS}${deployfile}..."
	cd ${DIR}/deploy/tmp
	tar czf ../${KERNEL_UTS}${deployfile} *

	cd ${DIR}/
	rm -rf ${DIR}/deploy/tmp || true

	if [ ! -f "${DIR}/deploy/${KERNEL_UTS}${deployfile}" ] ; then
		export ERROR_MSG="File Generation Failure: [${KERNEL_UTS}${deployfile}]"
		/bin/sh -e "${DIR}/scripts/error.sh" && { exit 1 ; }
	else
		ls -lh "${DIR}/deploy/${KERNEL_UTS}${deployfile}"
	fi
}

make_firmware_pkg () {
	echo "make_firmware_pkg"
	pkg="firmware"
	make_pkg
}

make_dtbs_pkg () {
	pkg="dtbs"
	make_pkg
}

/bin/sh -e ${DIR}/tools/host_det.sh || { exit 1 ; }

if [ ! -f ${DIR}/system.sh ] ; then
	cp ${DIR}/system.sh.sample ${DIR}/system.sh
else
	#fixes for bash -> sh conversion...
	sed -i 's/bash/sh/g' ${DIR}/system.sh
	sed -i 's/==/=/g' ${DIR}/system.sh
fi

unset CC
unset LINUX_GIT
. ${DIR}/system.sh
/bin/sh -e "${DIR}/scripts/gcc.sh" || { exit 1 ; }
. ${DIR}/.CC
echo "debug: CC=${CC}"

. ${DIR}/version.sh
BUILDREV=`date -u +%Y%m%d%H%M%S`
DEB_PKGVERSION=${KERNEL_REL}-${BUILD}+${DISTRO}${BUILDREV}


export LINUX_GIT

unset FULL_REBUILD
#FULL_REBUILD=1
if [ "${FULL_REBUILD}" ] ; then
	/bin/sh -e "${DIR}/scripts/git.sh" || { exit 1 ; }

	if [ "${RUN_BISECT}" ] ; then
		/bin/sh -e "${DIR}/scripts/bisect.sh" || { exit 1 ; }
	fi

	if [ "${PULL_DEV}" ] ; then
		pull_dev
	else
		patch_kernel
	fi

	copy_defconfig
fi
if [ ! ${AUTO_BUILD} ] ; then
	make_menuconfig
fi
make_deb
#~ make_firmware_pkg
#~ if [ "x${DTBS}" != "x" ] ; then
	#~ make_dtbs_pkg
#~ fi
