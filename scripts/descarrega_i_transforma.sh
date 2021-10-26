#!/bin/bash

#
# descarrega i transforma - executar un únic cop
# 

## from 
## version for the image in numbers (14.04, 16.04, 18.04, etc.)
ubuntuversion="20.04"
## image type: ova, vmdk, img, tar.gz
imagetype="img"


## URL to most recent cloud image
releases_url="https://cloud-images.ubuntu.com/releases/${ubuntuversion}/release/"
img_url="${releases_url}/ubuntu-${ubuntuversion}-server-cloudimg-amd64.${imagetype}"

## download a cloud image to run, and convert it to virtualbox 'vdi' format
img_dist="${img_url##*/}"
img_raw="${img_dist%.img}.raw"
#my_disk1="ubuntu-${ubuntuversion}-cloud-virtualbox-${versio}.vdi"
wget $img_url -O "$img_dist"
qemu-img resize "${img_dist}" 20G
qemu-img convert -O raw "${img_dist}" "${img_raw}"
