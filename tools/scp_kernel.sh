#!/bin/bash
function usage {
  echo "USAGE: tools/scp_kernel.sh root@host [port]"
  exit 1
}

if [ $# -lt 1 ]
then
    usage
fi

if [ $# -gt 2 ]
then
    usage
fi
PORT=$2
: ${PORT:=22}



echo "kernl version is $kernel_version"

#cat deploy/$kernel_version-firmware.tar.gz | ssh $1 -p $PORT "tar xfvz - -C /lib/firmware/"


cat deploy/$kernel_version-modules.tar.gz  | ssh $1 -p $PORT "tar xfvz - -C /"
cat deploy/$kernel_version-dtbs.tar.gz  | ssh $1 -p $PORT "tar xfvz - -C /boot/dtbs/"
scp -P $PORT deploy/$kernel_version.zImage  $1:/boot/zImage
