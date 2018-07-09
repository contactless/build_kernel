#!/bin/bash
set -e
#set -x

[[ "$#" == "1" ]] || {
	echo "Usage: $0 <initramfs>"
}

INITRAMFS="$(readlink -f "$1")"

export KERNEL_FLAVOUR=${KERNEL_FLAVOUR:-wb6_initramfs}

source  ./version.sh
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

make_config

KCONFIG=${KBUILD_OUTPUT}/.config

rm -rf "$INITRAMFS/lib/modules"
sed -ri "s#^CONFIG_INITRAMFS_SOURCE=.*#CONFIG_INITRAMFS_SOURCE=\"$INITRAMFS\"#" "$KCONFIG"

pushd "$SRCDIR"
make -j${CORES} ARCH=arm INSTALL_MOD_PATH="${INITRAMFS}"
make -j${CORES} ARCH=arm INSTALL_MOD_PATH="${INITRAMFS}" modules modules_install zImage dtbs

if [[ -n "$APPEND_DT" ]]; then
	cat $KBUILD_OUTPUT/arch/arm/boot/dts/$APPEND_DT.dtb >> $KBUILD_OUTPUT/arch/arm/boot/zImage
fi
popd

DESTDIR="$PKGDIR/$KERNEL_FLAVOUR"
rm -rf "$DESTDIR"
mkdir -p "$DESTDIR"
cp "$KBUILD_OUTPUT/arch/arm/boot/zImage" "$DESTDIR"
cp "$KBUILD_OUTPUT/arch/arm/boot/dts/"*.dtb "$DESTDIR"
