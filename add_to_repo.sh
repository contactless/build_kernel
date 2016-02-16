#!/bin/sh
cd deploy
add_deb.sh `readlink linux-headers_all.deb` `readlink linux-image_armel.deb` `readlink linux-latest_all.deb` `readlink linux-firmware-image_all.deb`

