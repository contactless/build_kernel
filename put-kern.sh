#!/bin/sh

#Отправка ядра, дерева и модулей на плату. Каталоги /boot/$KERN и /lib/modules/$KERN соотв. 
#KERN получаем из include/generated/uts_release.h после успешной сборки.

#Аргумент1 ком. строки - BRD=KERNEL_FLAVOUR=wb2|wb6
BRD=${1:-wb6}
echo BRD=$BRD

#Скрипту нужен BRD. На выходе много переменных, без экспорта.
. ./vars.sh

#DTB1=imx6ul-wirenboard660.dtb
#DTB2=imx28-wirenboard58.dtb
TAR=mod.tgz
TARPATH=$INSTM/lib/modules
TARFULL=$TARPATH/$TAR

try make $KMAKESTR INSTALL_MOD_PATH=$INSTM modules_install

#Получить строку вида 4.9.22ivz после сборки ядра. 
get_kern_ver
[ -z "$KERN" ] && die "?Cant get kernel version."

#Создаем архив с модулями.
#Чтобы не было ошибки file changed as we read it, можно сделать touch + --exclude (или не делать - не мешает).
touch $TARFULL
tar -czf $TARFULL -C $TARPATH --exclude=build --exclude=source --exclude=./$TAR .

#Для скриптов отправки надо TARGET=wb5 если wb2.
export TARGET=$TARGET

#Ядро, дерево устройств, архив с модулями отправляем на плату.
try ./sftp2.sh "\
put $KBUILD_OUTPUT/arch/arm/boot/zImage /boot/vmlinuz-$KERN \n
mkdir /usr/lib/linux-image-$KERN \n
cd /usr/lib/linux-image-$KERN \n
mput $KBUILD_OUTPUT/arch/arm/boot/dts/*wirenboard*.dtb \n
put $TARFULL /lib/modules/$TAR \n
"
#Распаковываем архив с модулями.
try ./plink2.sh "rm -rf /lib/modules/$KERN; tar -xf /lib/modules/$TAR -C /lib/modules/"
