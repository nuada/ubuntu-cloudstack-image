#!/bin/bash

IMAGE_NAME=trusty-server-cloudimg-amd64-disk1

# Mount qcow & give it access to sys resources & Internet
sudo modprobe nbd max_part=14
sudo qemu-nbd -c /dev/nbd0 ${IMAGE_NAME}.img
sudo mkdir /mnt/image

sudo mount /dev/nbd0p1 /mnt/image
sudo mount --bind /dev /mnt/image/dev
sudo mount --bind /proc /mnt/image/proc
sudo mv /mnt/image/etc/resolv.conf /mnt/image/etc/resolv.conf.bak
sudo cp -f /etc/resolv.conf /mnt/image/etc/resolv.conf

# Modify qcow
sudo cp xenify_trusty.sh /mnt/image/tmp/
sudo chroot /mnt/image /bin/bash -c "su - -c 'cd /tmp ; ./xenify_trusty.sh'"

# Unmount modified qcow & cleanup
sudo mv /mnt/image/etc/resolv.conf.bak /mnt/image/etc/resolv.conf
sudo rm -rf /mtn/image/tmp/*
sudo umount -l /mnt/image/dev/
sudo umount -l /mnt/image/proc/
sudo umount -l /mnt/image
sudo qemu-nbd -d /dev/nbd0
sudo rm -rf /mnt/image

# Convert QCOW2 to VHD and compress
qemu-img convert -f qcow2 -O vpc ${IMAGE_NAME}.img ${IMAGE_NAME}.vhd
bzip2 ${IMAGE_NAME}.vhd
