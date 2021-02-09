#!/bin/sh

#Собрать ядро, дерево устройств и модули под одно семейство контроллеров. 
#Входные переменные: [BRD] (аналог KERNEL_FLAVOUR) = wb2|wb6

. ./vars.sh

#Не меняем .defconfig
#try time make $KMAKESTR $KERNEL_DEFCONFIG

try time make $KMAKESTR dtbs zImage modules

#Не собираем .deb.
#try time make $KMAKESTR bindeb-pkg
