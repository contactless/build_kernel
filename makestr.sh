#!/bin/bash

#Скрипт выполняет команду make с переменными, необходимыми для команд сборки ядра.
#Вся ком. строка передается в make.
#Входные переменные: [BRD] (аналог KERNEL_FLAVOUR) = wb2|wb6
#Пример: BRD=wb6 ./makestr.sh menuconfig

. vars.sh

try time make $KMAKESTR $@
