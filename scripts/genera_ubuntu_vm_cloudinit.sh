#!/bin/bash
# from: https://gist.github.com/leogallego/a614c61457ed22cb1d960b32de4a1b01


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

els següents dos passes ja han estat creats a descarrega_i_transforma.sh
## wget $img_url -O "$img_dist"
##qemu-img convert -O raw "${img_dist}" "${img_raw}"

## =============== crea a partior de descàrrega convertida

versio=17
my_disk1="ubuntu-${ubuntuversion}-cloud-virtualbox-${versio}.vdi"
vboxmanage convertfromraw "$img_raw" "$my_disk1"



my_disk1="ubuntu-${ubuntuversion}-cloud-virtualbox-${versio}.vdi"
seed_iso="my-seed.iso"
##
## create a virtual machine using vboxmanage
##
vmname="ubuntu-${ubuntuversion}-versio-${versio}"
vboxmanage createvm --name "$vmname" --register
vboxmanage modifyvm "$vmname" \
   --memory 1024 --nested-hw-virt on --graphicscontroller vmsvga --boot1 disk --acpi on \
   --nic1 nat --natpf1 "guestssh,tcp,,2222,,22"
## Another option for networking would be:
##   --nic1 bridged --bridgeadapter1 eth0
vboxmanage storagectl "$vmname" --name "IDE_0"  --add ide
vboxmanage storageattach "$vmname" \
    --storagectl "IDE_0" --port 0 --device 0 \
    --type hdd --medium "$my_disk1"
vboxmanage storageattach "$vmname" \
    --storagectl "IDE_0" --port 1 --device 0 \
    --type dvddrive --medium "$seed_iso"


