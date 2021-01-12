export BUILD_BRANCH=dev/v5.8.9
export KERNEL_BRANCH=myrebase7

#Перенесено в build_deb_all.sh - стало не нужно.
#export PATH=/usr/local/go/bin:/home/ivan/wbdev/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
#umask 022

export WBDEV_IMAGE=contactless/devenv:test  # e7ce50351ace  # af9c99e4bb61

#Не надо.
#docker pull $WBDEV_IMAGE

./build_deb_all.sh
