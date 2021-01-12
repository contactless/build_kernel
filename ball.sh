#!/bin/bash

#Сборка в отдельном каталоге под каждый KERNEL_FLAVOUR
#Сбрасывает .config на defconfig
for BRD in wb2 wb6; do
    #Переменные настраиваются по BRD.
    . vars.sh
    try make $KMAKESTR $KERNEL_DEFCONFIG
    try time make $KMAKESTR zImage modules dtbs
    try time make $KMAKESTR bindeb-pkg
done
