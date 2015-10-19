#!/bin/bash

if [ $# -ne 1 ]
then
  echo "USAGE: tools/scp_kernel.sh root@host"
  exit 1
fi



scp deploy/linux-image_armel.deb deploy/linux-firmware-image_armel.deb $1:
ssh $1 "dpkg -i linux-image_armel.deb linux-firmware-image_armel.deb"


