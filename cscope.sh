#!/bin/sh

#Запуск просмотрщика cscope. 
#Предварительно надо сгенерировать базу с помощью cscopegen.sh
#Входные переменные: [BRD] (аналог KERNEL_FLAVOUR) = wb2|wb6

BRD=${BRD:-wb6}
. ./vars.sh

cscope -p4 -d -f build/$BRD/cscope.out
