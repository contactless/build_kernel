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
	cd ${DIR}/KERNEL/
	make ARCH=arm CROSS_COMPILE=${CC} menuconfig
	#~ cp -v .config ${DIR}/patches/defconfig
	cd ${DIR}/
}

make_kernel () {
	image="zImage"
	unset address


	cd ${DIR}/KERNEL/

	# Cleanup DTC in case there are ARM build leftovers
	pushd scripts/dtc
	make -f Makefile.standalone clean
	popd

	echo "-----------------------------"
	echo "make -j${CORES} ARCH=arm LOCALVERSION=-${BUILD} CROSS_COMPILE=${CC} ${address} ${image} modules"
	echo "-----------------------------"
	make -j${CORES} ARCH=arm LOCALVERSION=-${BUILD} CROSS_COMPILE=${CC} ${address} ${image} modules

	unset DTBS
	cat ${DIR}/KERNEL/arch/arm/Makefile | grep "dtbs:" >/dev/null 2>&1 && DTBS=1
	if [ "x${DTBS}" != "x" ] ; then
		echo "-----------------------------"
		echo "make -j${CORES} ARCH=arm LOCALVERSION=-${BUILD} CROSS_COMPILE=${CC} dtbs"
		echo "-----------------------------"
		make -j${CORES} ARCH=arm LOCALVERSION=-${BUILD} CROSS_COMPILE=${CC} dtbs
		ls arch/arm/boot/* | grep dtb >/dev/null 2>&1 || unset DTBS
	fi

	KERNEL_UTS=$(cat ${DIR}/KERNEL/include/generated/utsrelease.h | awk '{print $3}' | sed 's/\"//g' )

	if [ -f "${DIR}/deploy/${KERNEL_UTS}.${image}" ] ; then
		rm -rf "${DIR}/deploy/${KERNEL_UTS}.${image}" || true
		rm -rf "${DIR}/deploy/${KERNEL_UTS}.config" || true
	fi

	if [ -f ./arch/arm/boot/${image} ] ; then
		cp -v arch/arm/boot/${image} "${DIR}/deploy/${KERNEL_UTS}.${image}"
		cp -v .config "${DIR}/deploy/${KERNEL_UTS}.config"
	fi

	cd ${DIR}/

	if [ ! -f "${DIR}/deploy/${KERNEL_UTS}.${image}" ] ; then
		export ERROR_MSG="File Generation Failure: [${KERNEL_UTS}.${image}]"
		/bin/sh -e "${DIR}/scripts/error.sh" && { exit 1 ; }
	else
		ls -lh "${DIR}/deploy/${KERNEL_UTS}.${image}"
	fi
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

make_modules_pkg () {
	pkg="modules"
	make_pkg
}

make_firmware_pkg () {
	pkg="firmware"
	make_pkg
}

make_dtbs_pkg () {
	pkg="dtbs"
	make_pkg
}


#~ make_menuconfig
make_kernel
make_modules_pkg
make_firmware_pkg
if [ "x${DTBS}" != "x" ] ; then
	make_dtbs_pkg
fi
echo "-----------------------------"
echo "Script Complete"
echo "$ export kernel_version=${KERNEL_UTS}]"
echo "-----------------------------"
