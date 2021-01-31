#!/bin/sh

#Скрипт получает команду, можно без кавычек, в командной строке. Вся строка записывается в файл и передается psftp.
#Отдельные команды psftp разделяются CR.
# ./sftp2.sh "
# put a.a
# "

. ./psvars.sh

set -x

TMPF=`mktemp`
printf "$*" > $TMPF
psftp $TARGET $TPORT -l $TUSER -i $TKEY -be -b $TMPF
#rm $TMPF  #Not doing, hides return code. /tmp is cleared on restart.
