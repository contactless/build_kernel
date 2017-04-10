#!/bin/bash
cd deploy
add_deb.sh $(find deploy -type l -exec readlink '{}' \;)
