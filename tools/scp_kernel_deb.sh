#!/bin/bash

if [ $# -ne 1 ]
then
  echo "USAGE: tools/scp_kernel.sh root@host"
  exit 1
fi

echo "kernl version is $kernel_version"


scp deploy/linux-*-$kernel_version* $1:
ssh $1 "dpkg -i linux-*-$kernel_version*.deb"


