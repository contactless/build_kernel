#!/bin/sh

#Генерация файлов для просмотрщика кода cscope, в каталоге build/
#Входные переменные: [BRD] (аналог KERNEL_FLAVOUR) = wb2|wb6

BRD=${BRD:-wb6}
. ./vars.sh

./makestr.sh cscope
