#!/bin/bash

opkg update
opkg install block-mount kmod-fs-ext4 kmod-usb-storage-extras e2fsprogs fdisk

#Format the SD card. ext4 file system is used in this example:
mkfs.ext4 /dev/mmcblk0p1

#Duplicate the current root FS and move it to the SD card by typing the following commands:
mount /dev/mmcblk0p1 /mnt
tar -C /overlay -cvf - . | tar -C /mnt -xf -
umount /mnt

#Create a fstab template, for example:
block detect > /etc/config/fstab

#Open the fstab configuration and edit it
sed -i -- 's/mnt\/mcblk0p1/overlay/g' *
sed -i -- 's/enabled '0'/enabled '1'/g' *
