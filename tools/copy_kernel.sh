#!/bin/bash

if [ $# -ne 1 ]
then
  echo "USAGE: tools/copy_kernel.sh <path to rootfs>"
  exit 1
fi

echo "kernl version is $kernel_version"

sudo tar xfv deploy/$kernel_version-firmware.tar.gz -C $1/lib/firmware/
sudo tar xfv deploy/$kernel_version-modules.tar.gz -C $1/
sudo tar xfv deploy/$kernel_version-dtbs.tar.gz -C $1/boot/dtbs/
sudo cp deploy/$kernel_version.zImage  $1/boot/zImage
