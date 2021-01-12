#!/bin/bash

#Создать нужные переменные.
#Входной параметр BRD=wb2|wb6, совпадает с KERNEL_FLAVOUR в build_deb_all.sh
#Переменные не экспортируются, нужные явно задаются в дочерних вызовах, чтобы было понятно, что куда идет.

yell() { echo "$0: $*" >&2; }
die() { echo -e "\e[31m$*\e[0m"; exit 1; }
try() { "$@" || die "cannot $*"; }

set -x

case "$BRD" in
  wb2)
    DEBARCH=armel
    KERNEL_DEFCONFIG=mxs_wirenboard_defconfig
    TARGET=wb5
    ;;
  wb6)
    DEBARCH=armhf
    KERNEL_DEFCONFIG=imx6_wirenboard_defconfig
    TARGET=wb6
    ;;
  *)
    die "Unknown BRD aka KERNEL_FLAVOUR"
esac

CROSS_COMPILE=arm-linux-gnueabihf-
KBUILD_OUTPUT=$PWD/build/$BRD
INSTM=$KBUILD_OUTPUT/_mod

#Строка, с которой вызываются все kernel make.
KMAKESTR="CROSS_COMPILE=$CROSS_COMPILE KBUILD_OUTPUT=$KBUILD_OUTPUT -C KERNEL -j8 ARCH=arm LOCALVERSION=ivz DEBARCH=$DEBARCH"
