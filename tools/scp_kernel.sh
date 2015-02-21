#!/bin/bash

if [ $# -ne 1 ]
then
  echo "USAGE: tools/scp_kernel.sh root@host"
  exit 1
fi

echo "kernl version is $kernel_version"

#cat deploy/$kernel_version-firmware.tar.gz | ssh $1 "tar xfvz - -C /lib/firmware/"


cat deploy/$kernel_version-modules.tar.gz  | ssh $1 "tar xfvz - -C /"
cat deploy/$kernel_version-dtbs.tar.gz  | ssh $1 "tar xfvz - -C /boot/dtbs/"
scp deploy/$kernel_version.zImage  $1:/boot/zImage
