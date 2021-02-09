#!/bin/sh

#Сохранить в обратную сторону: .config -> defconfig и переименовать его по типу контроллера.
#Входные переменные: [BRD] (аналог KERNEL_FLAVOUR) = wb2|wb6

. ./vars.sh

try time make $KMAKESTR savedefconfig
mv $KBUILD_OUTPUT/defconfig KERNEL/arch/arm/configs/_defconfig_$BRD