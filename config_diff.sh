#!/bin/bash
cd KERNEL
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- savedefconfig
scripts/diffconfig ./arch/arm/configs/mxs_wirenboard_defconfig defconfig | sed 's/^-/\x1b[41m-/;s/^+/\x1b[42m+/;s/^@/\x1b[34m@/;s/$/\x1b[0m/'

