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

set -x
source version.sh
setup_kernel_vars || exit $?

export KBUILD_OUTPUT=$DIR/build/$KERNEL_FLAVOUR
mkdir -p "$KBUILD_OUTPUT"

make_config() {
	pushd "$SRCDIR"
	if [[ -t 0 && -e "${KBUILD_OUTPUT}/.config" ]]; then
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
	popd
}

make_menuconfig () {
	pushd "$SRCDIR"
	make ARCH=arm menuconfig
	#~ cp -v .config ${DIR}/patches/defconfig
	popd
}

make_deb () {
	[[ -e "$(which depmod)" ]] || {
		echo "Need depmod to build modules correctly. Please install kmod package"
		exit 1
	}

	pushd "${SRCDIR}"
	make -j${CORES} ARCH=arm KBUILD_DEBARCH=${DEBARCH} zImage modules dtbs

	KERNEL_UTS=$(cat ${KBUILD_OUTPUT}/include/generated/utsrelease.h | awk '{print $3}' | sed 's/\"//g' )
	echo "kernel uts= $KERNEL_UTS"
	DISTRO=wb
	DEB_PKGVERSION=${KERNEL_UTS}+${DISTRO}${BUILDREV}

	echo "-----------------------------"
	echo "make -j${CORES} ARCH=arm KBUILD_DEBARCH=${DEBARCH} KDEB_PKGVERSION=${DEB_PKGVERSION} bindeb-pkg"
	echo "-----------------------------"
	make -j${CORES} ARCH=arm KBUILD_DEBARCH=${DEBARCH} KDEB_PKGVERSION=${DEB_PKGVERSION} bindeb-pkg
	mv ${KBUILD_OUTPUT}/../*.deb ${PKGDIR}


	ln -s -f linux-image-${KERNEL_UTS}_${DEB_PKGVERSION}_${DEBARCH}.deb ${PKGDIR}/linux-image_${KERNEL_FLAVOUR}_${DEBARCH}.deb
	ln -s -f linux-headers-${KERNEL_UTS}_${DEB_PKGVERSION}_${DEBARCH}.deb ${PKGDIR}/linux-headers_${KERNEL_FLAVOUR}_${DEBARCH}.deb
	ln -s -f linux-libc-dev_${DEB_PKGVERSION}_${DEBARCH}.deb ${PKGDIR}/linux-libc-dev_${KERNEL_FLAVOUR}_${DEBARCH}.deb	# FIXME: it should be built per-arch, and not per-flavour

	METATMPDIR=`mktemp -d`
	METAPKGNAME="linux-image-${KERNEL_FLAVOUR}_${DEB_PKGVERSION}_${DEBARCH}"
	mkdir $METATMPDIR/${METAPKGNAME}
	mkdir $METATMPDIR/${METAPKGNAME}/DEBIAN
	cat <<EOF > "$METATMPDIR/${METAPKGNAME}/DEBIAN/control"
Package: linux-image-${KERNEL_FLAVOUR}
Version: $DEB_PKGVERSION
Section: main
Priority: optional
Architecture: $DEBARCH
Breaks: wb-hwconf-manager (<< 1.38.2)
Depends: linux-image-${KERNEL_UTS} (>= $DEB_PKGVERSION)
Provides: linux-image-${DISTRO}
Replaces: linux-image-4.1.15-imxv5-x0.1, linux-image-4.9.6-wb
Conflicts: linux-image-4.1.15-imxv5-x0.1, linux-image-4.9.6-wb, wb-configs (<= 1.72)
Installed-Size:
Maintainer: Evgeny Boger
Description: A metapackage for latest Linux kernel for ${FLAVOUR_DESC}
EOF
	mkdir -p "$METATMPDIR/$METAPKGNAME/etc/kernel/postinst.d"
	cp "$DIR/wb.postinst" "$METATMPDIR/$METAPKGNAME/etc/kernel/postinst.d/01wb"

	dpkg --build ${METATMPDIR}/${METAPKGNAME}

	cp ${METATMPDIR}/${METAPKGNAME}.deb ${DIR}/deploy/
	ln -s -f ${METAPKGNAME}.deb ${DIR}/deploy/linux-image-${KERNEL_FLAVOUR}_${DEBARCH}.deb
	rm -rf ${METATMPDIR}

	popd
}

echo "Building kernel packages for $KERNEL_FLAVOUR ($FLAVOUR_DESC)"
echo "Architecture: ${DEBARCH}"
echo "Package version: ${DEB_PKGVERSION}"
echo "Config: ${KERNEL_DEFCONFIG}"

make_config
#~ make_menuconfig
make_deb
