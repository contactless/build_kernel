#!/bin/bash

if [ $# -ne 1 ]
then
  echo "USAGE: tools/copy_kernel.sh <path to rootfs>"
  exit 1
fi


sudo tar xfv deploy/3.11.0-rc7-imxv5-x0.7-firmware.tar.gz -C $1/lib/firmware/
sudo tar xfv deploy/3.11.0-rc7-imxv5-x0.7-modules.tar.gz -C $1/
sudo tar xfv deploy/3.11.0-rc7-imxv5-x0.7-dtbs.tar.gz -C $1/boot/dtbs/
sudo cp deploy/3.11.0-rc7-imxv5-x0.7.zImage  $1/boot/zImage
