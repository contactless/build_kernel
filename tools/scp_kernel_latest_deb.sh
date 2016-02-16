#!/bin/bash

if [ $# -gt 2 ] || [ $# -lt 1 ]
then
  echo "USAGE: tools/scp_kernel.sh root@host [port]"
  exit 1
fi

PORT="${2:-22}"
echo $PORT


scp -P ${PORT} deploy/linux-image_armel.deb deploy/linux-firmware-image_all.deb $1:
ssh -p $PORT $1 "dpkg -i linux-image_armel.deb linux-firmware-image_all.deb"


