#!/bin/bash
set -x 

BASE_DIR=/root/iso 
CENTOS_DIR=/mnt/iso
CUSTOM_DIR=/root/iso/custom_centos7.0
ISO=$(basename $CUSTOM_DIR).iso

# edit $BASE_DIR/ks.cfg

[[ ! -d $CENTOS_DIR ]] && mkdir -p $CENTOS_DIR
umount $CENTOS_DIR
mount -o loop $BASE_DIR/CentOS-7-x86_64-DVD-1511.iso $CENTOS_DIR
[[ ! -d $CUSTOM_DIR ]] && mkdir -p $CUSTOM_DIR
cp -rf $CENTOS_DIR/* $CUSTOM_DIR/
cp -f $CENTOS_DIR/.discinfo $CUSTOM_DIR/
cp -f $BASE_DIR/Packages/*.rpm $CUSTOM_DIR/Packages/
cp -f $BASE_DIR/EFI/BOOT/grub.cfg $CUSTOM_DIR/EFI/BOOT/grub.cfg
cp -f $BASE_DIR/isolinux/isolinux.cfg $CUSTOM_DIR/isolinux/isolinux.cfg
cp -f $BASE_DIR/ks.cfg $CUSTOM_DIR/ks.cfg

cd $CUSTOM_DIR/
createrepo -g repodata/*-comps.xml .
genisoimage -v -cache-inodes -joliet-long -R -J -T -V BC -o $BASE_DIR/$ISO -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -b images/efiboot.img -no-emul-boot .
