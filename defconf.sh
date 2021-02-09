#!/bin/bash

#Сделать .config ядра по соотв. defconfig, в зависимости от вида контроллера.
#Входные переменные: [BRD] (аналог KERNEL_FLAVOUR) = wb2|wb6

BRD=${BRD:-wb6}
. vars.sh

try time make $KMAKESTR $KERNEL_DEFCONFIG
