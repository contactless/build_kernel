#!/bin/bash

#Аргумент1 ком. строки - BRD=KERNEL_FLAVOUR=wb2|wb6
BRD=${1:-wb6}
. vars.sh

try time make $KMAKESTR savedefconfig
mv defconfig arch/arm/configs/_defconfig