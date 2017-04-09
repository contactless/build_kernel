#!/bin/bash

. ./version.sh
setup_deb_vars || exit $?

DTCVERSION="1.4.1+${DISTRO}${BUILDREV}"
DTCPKGNAME="device-tree-compiler_${DTCVERSION}_${DEBARCH}"
DTCTMPDIR=`mktemp -d`
unset TARGET_ARCH	# it breaks dtc build for some strange reason

[[ -e "${SRCDIR}/scripts/dtc/Makefile.standalone" ]] || {
	echo "Not building device-tree-compiler for ${DEBARCH} due to absence of Makefile.standalone"
	return
}

pushd "${SRCDIR}/scripts/dtc"
make -f Makefile.standalone clean &&
make -f Makefile.standalone CC=${CROSS_COMPILE}gcc &&
fakeroot make -f Makefile.standalone DESTDIR="$DTCTMPDIR/$DTCPKGNAME" install
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
cp ${DTCTMPDIR}/${DTCPKGNAME}.deb ${PKGDIR}
ln -s -f ${DTCPKGNAME}.deb ${DIR}/deploy/device-tree-compiler_${DEBARCH}.deb
rm -rf ${DTCTMPDIR}
