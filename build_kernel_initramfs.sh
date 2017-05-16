#!/bin/bash -x
set -e

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
make -j${CORES} ARCH=arm INSTALL_MOD_PATH="${INITRAMFS}" modules modules_install zImage dtbs
popd

