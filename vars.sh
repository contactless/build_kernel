#!/bin/bash

#Создать нужные переменные.
#Входной параметр BRD=wb2|wb6, совпадает с KERNEL_FLAVOUR в build_deb_all.sh
#Переменные не экспортируются, нужные явно задаются в дочерних вызовах, чтобы было понятно, что куда идет.

yell() { echo "$0: $*" >&2; }
die() { echo -e "\e[31m$*\e[0m"; exit 1; }
try() { "$@" || die "cannot $*"; }

#Получить строку вида 4.9.22ivz после сборки ядра в переменную KERN
get_kern_ver()
{
  KERN=$(cat "$KBUILD_OUTPUT/include/generated/utsrelease.h" | awk '{print $3}' | sed 's/\"//g' )
}

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

#Префикс для кросс-компиляции
CROSS_COMPILE=arm-linux-gnueabihf-
#Каталог, куда идут все результаты сборки
KBUILD_OUTPUT=$PWD/build/$BRD
#Каталог INSTALL_MOD_PATH для put-kern.sh
INSTM=$KBUILD_OUTPUT/_mod
#Исходники ядра
KERNSRC=KERNEL

#Строка, с которой вызываются все kernel make.
KMAKESTR="CROSS_COMPILE=$CROSS_COMPILE KBUILD_OUTPUT=$KBUILD_OUTPUT -C $KERNSRC -j8 ARCH=arm LOCALVERSION=ivz DEBARCH=$DEBARCH"

