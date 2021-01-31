#!/bin/sh

#Отправляет перечисленные модули на плату в каталог с модулями. Может перезагрузить модуль.

#Аргумент1 ком. строки - BRD=KERNEL_FLAVOUR=wb2|wb6
BRD=${1:-wb6}
echo BRD=$BRD

#Скрипту нужен BRD. На выходе много переменных, без экспорта.
. ./vars.sh

get_kern_ver
[ -z "$KERN" ] && die "?Cant get kernel version."

#set +x

W1F=$KBUILD_OUTPUT/drivers/w1
W1T=/lib/modules/$KERN/kernel/drivers/w1
PUTSTR=""
for F in 'wire.ko' 'slaves/w1_therm.ko' 'masters/w1-gpio.ko'
do
  PUTSTR=$PUTSTR"put $W1F/$F $W1T/$F \n"
done
#echo $PUTSTR

try ./sftp2.sh "$PUTSTR"

#Перегрузка временно убрана.
#try ./plink2.sh "~/w1reload.sh"

