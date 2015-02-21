#!/bin/bash

if [ $# -ne 2 ]
then
  echo "USAGE: tools/copy_kernel_deb.sh <path to rootfs> <path to deb>"
  exit 1
fi


sudo mkdir -p $1/tmp
sudo cp $2 $1/tmp/tmppkg.deb

sudo mkdir $1/dev/pts
sudo mount -t devpts devpts $1/dev/pts
sudo mount -t proc proc $1/proc

sudo chroot $1 dpkg -i /tmp/tmppkg.deb

sudo umount $1/dev/pts
sudo umount $1/proc
sudo umount $1/dev


