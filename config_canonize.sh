#!/bin/bash
./config_diff.sh

cd KERNEL
cp defconfig arch/arm/configs/mxs_wirenboard_defconfig

