#!/bin/bash

#Аргумент1 ком. строки - BRD=KERNEL_FLAVOUR=wb2|wb6
BRD=${1:-wb6}
. vars.sh

#try time make $KMAKESTR $KERNEL_DEFCONFIG
try time make $KMAKESTR dtbs zImage modules
#try time make $KMAKESTR bindeb-pkg
