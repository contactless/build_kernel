#!/bin/bash

if [ $# -ne 1 ]
then
  echo "USAGE: tools/copy_kernel_deb.sh <path to rootfs>"
  exit 1
fi


mkdir -p $1/tmp
mkdir $1/dev/pts
mount -t devpts devpts $1/dev/pts
mount -t proc proc $1/proc


for debpkg in deploy/linux-image_armel.deb deploy/linux-firmware-image_all.deb; do
	cp $debpkg $1/tmp/tmppkg.deb;
	chroot $1 dpkg -i /tmp/tmppkg.deb;
done

umount $1/dev/pts
umount $1/proc
umount $1/dev
