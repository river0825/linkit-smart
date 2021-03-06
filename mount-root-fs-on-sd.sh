#!/bin/bash

#check if sd card has been mount as root
if df -h | grep -q  "mcblk0p1.*/overlay$"; then
        echo "sd card has been mount as root, exit"
        exit 0
fi

while true; do
	read -p "Following process will ERASE all data in you sdcard. Do you want to proceed? (Y/N)" yn
	case $yn in
		[Yy]* ) break ;;
		[Nn]* ) echo "program exit"; exit;;
		* ) echo "Please answer Y/N";;
	esac
done

echo "========= updating opkg ========="
opkg update
opkg install block-mount kmod-fs-ext4 kmod-usb-storage-extras e2fsprogs fdisk

echo "========= Format the SD card. ext4 file system ========="
mkfs.ext4 /dev/mmcblk0p1

echo "========= Duplicate the current root FS and move it to the sdcard ========="
if ! mount /dev/mmcblk0p1 /mnt; then
	echo "sdcard mount fail, try again with another sdcard"
	exit
fi
tar -C /overlay -cvf - . | tar -C /mnt -xf -
umount /mnt

echo "========= Create a fstab template ========="
block detect > /etc/config/fstab

echo "========= Open the fstab configuration and edit it ========="
sed -i -- "s/mnt\/mmcblk0p1/overlay/g" /etc/config/fstab
sed -i -- "s/enabled\t'0'/enabled\t'1'/g" /etc/config/fstab

while true; do
	read -p "All setting have been done, do you want to reboot? (Y/N)" yn
	case $yn in
		[Yy]* ) reboot; break ;;
		[Nn]* ) echo "========= you have to reboot to make it work ========="; exit;;
		* ) echo "Please answer Y/N";;
	esac
done
 
