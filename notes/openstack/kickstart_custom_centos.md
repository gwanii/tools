## CentOS镜像制作(kickstart)

### 一、 kickstart介绍
```
关于kickstart的介绍参见google.com
```

### 二、 Step by step

#### 0. 安装制作工具
```
[root@ctl ~]# yum install genisoimage
[root@ctl ~]# yum install createrepo
```

#### 1. 复制镜像文件
```
[root@ctl ~]# mount -o loop CentOS-7.0-1406-x86_64-DVD.iso /mnt/iso/
[root@ctl ~]# mkdir custom_iso
[root@ctl ~]# cp -rf /mnt/iso/* ~/custom_iso
[root@ctl ~]# cp /mnt/iso/.discinfo ~/custom_iso	# 单独复制 .discinfo文件
```

#### 2. 编辑kickstart.cfg
```
# kickstart文件可以直接从anaconda-ks.cfg复制过来，也可以执行以下命令生成
[root@ctl ~]# system-config-kickstart --generate ks.cfg
[root@ctl ~]# vim ks.cfg
[root@ctl ~]# cat ks.cfg
#version=RHEL7
install	
cdrom	
graphical	    # 图形界面安装
firstboot --disable
keyboard --vckeymap=us --xlayouts='us'	   #键盘设置
lang en_US.UTF-8    # 语言设置
timezone Asia/Shanghai --isUtc --nontp	# 时区设置
network  --hostname=localhost.localdomain	# hostname
auth --enableshadow --passalgo=sha512
rootpw --iscrypted $6$teIrr6AtYhRgA7dc$wkMsFaZhU.yBIOMFoiJGNCTVESgorhNae8aWSmder6Q.zeWnW6EOFptr6CAxYyV3A5HrvfRTuhQ9f354YH1	 # root密码
selinux --permissive	# 开启selinux

%packages	# 定制安装软件包
# 基础软件
@^minimal
@core
kexec-tools
gcc
vim

# 需要定制安装的软件包
custom-A.x86_64
custom-B.x86_64
custom-C.x86_64

%end

%post	# 软件启动、初始化相关命令
systemctl stop firewalld
systemctl disable firewalld
systemctl enable iptables
systemctl enable NetworkManager

systemctl start custom-A
systemctl start custom-B
systemctl start custom-C

%end
```
#### 3. 编辑isolinux/isolinux.cfg
```
[root@ctl ~]# vim custom_iso/isolinux/isolinux.cfg
[root@ctl ~]# cat custom_iso/isolinux/isolinux.cfg
...
...
...
menu clear
menu background splash.png
menu title XXX Custom OS
menu vshift 8
menu rows 18
menu margin 8
...
...
...
label linux
  menu label ^Install XXX Custom OS
  menu default
  kernel vmlinuz
  append initrd=initrd.img inst.ks=hd:LABEL=BC:/ks.cfg inst.stage2=hd:LABEL=BC selinux=0 quiet

label check
  menu label Test this ^media & install XXX Custom OS
  kernel vmlinuz
  append initrd=initrd.img inst.stage2=hd:LABEL=BC rd.live.check quiet

menu separator # insert an empty line

# utilities submenu
menu begin ^Troubleshooting
  menu title Troubleshooting

label vesa
  menu indent count 5
  menu label Install XXX Custom OS in ^basic graphics mode
  text help
        Try this option out if you're having trouble installing
        XXX Custom OS.
  endtext
  kernel vmlinuz
  append initrd=initrd.img inst.stage2=hd:LABEL=BC xdriver=vesa nomodeset quiet

label rescue
  menu indent count 5
  menu label ^Rescue a XXX Custom OS system
  text help
        If the system will not boot, this lets you access files
        and edit config files to try to get it booting again.
  endtext
  kernel vmlinuz
  append initrd=initrd.img inst.stage2=hd:LABEL=BC rescue quiet
...
...
...
# memu label 后面的内容是在光盘引导起来菜单的内容，^后面的字母是菜单的快捷键；
# 通过inst.ks关键字指明ks.cfg文件位置；
# inst.stages2标识的是系统按照介质位置，这里使用hd:LABEL表明寻找的是label为BC的安装介质。

```

#### 4. 编辑EFI/BOOT/grub.cfg
```
[root@ctl ~]# vim custom_iso/EFI/BOOT/grub.cfg
[root@ctl ~]# cat custom_iso/EFI/BOOT/grub.cfg
...
...
...
search --no-floppy --set=root -l 'BC'

### BEGIN /etc/grub.d/10_linux ###
menuentry 'Install XXX Custom OS' --class fedora --class gnu-linux --class gnu --class os {
        linuxefi /images/pxeboot/vmlinuz ks=hd:LABEL=BC:/ks.cfg inst.stage2=hd:LABEL=BC selinux=0 quiet
        initrdefi /images/pxeboot/initrd.img
}
menuentry 'Test this media & install XXX Custom OS' --class fedora --class gnu-linux --class gnu --class os {
        linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=BC rd.live.check quiet
        initrdefi /images/pxeboot/initrd.img
}
submenu 'Troubleshooting -->' {
        menuentry 'Install XXX Custom OS in basic graphics mode' --class fedora --class gnu-linux --class gnu --class os {
                linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=BC xdriver=vesa nomodeset quiet
                initrdefi /images/pxeboot/initrd.img
        }
        menuentry 'Rescue a XXX Custom OS system' --class fedora --class gnu-linux --class gnu --class os {
                linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=BC rescue quiet
                initrdefi /images/pxeboot/initrd.img
        }
}
...
...
...
# 这里的inst.stages2和ks选项同上
```

#### 5. 复制需要定制安装的RPM安装包
```
[root@ctl ~]# cp custom-A.x86_64.rpm ~/custom_iso/Packages/
[root@ctl ~]# cp custom-B.x86_64.rpm ~/custom_iso/Packages/
[root@ctl ~]# cp custom-C.x86_64.rpm ~/custom_iso/Packages/
```

#### 6. 创建repo元数据
``` 
[root@ctl ~]# createrepo -g repodata/*comps.xml .
```

#### 7. 生成镜像
``` 
[root@ctl ~]# genisoimage -v -cache-inodes -joliet-long -R -J -T -V BC -o /root/baicells.iso -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -b images/efiboot.img -no-emul-boot .

# 注意 "-V BC" 选项对应 isolinux/isolinux.cfg 和 EFI/BOOT/grub.cfg 中的 "LABEL"
```
### 三、 参考文献
- CentOS7全自动安装光盘制作详解 http://xiaoli110.blog.51cto.com/1724/1617541
