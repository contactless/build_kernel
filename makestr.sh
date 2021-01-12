#!/bin/bash

#Ком. строка передается в make.
#Переменная BRD=KERNEL_FLAVOUR=wb2|wb6
#Пример: BRD=wb6 ./makestr.sh menuconfig
BRD=wb6
. vars.sh

try time make $KMAKESTR $@
