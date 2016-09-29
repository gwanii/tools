## OpenStack镜像制作

### 一、
选择一台支持kvm虚拟化的主机(安装virt-install, qemu-img, virt-viewer, virsh等)； 然后执行如下操作，注意注释部分
```
#!/bin/bash

# on host !!

NAME=centos7
ROOT_DISK=centos7.qcow2
CDROM=`pwd`/CentOS-7-x86_64-Minimal-1511.iso
qemu-img create -f qcow2 $ROOT_DISK 10G
sudo virt-install --virt-type kvm --name $NAME --ram 1024 \
  --disk $ROOT_DISK,format=qcow2 \
  --network network=default \
  --graphics vnc,listen=0.0.0.0 --noautoconsole \
  --os-type=linux --os-variant=rhel7 \
  --cdrom=$CDROM
virt-viewer centos7
sudo virsh start centos7
virt-viewer centos7

# after related operation on vm !!
sudo virt-sysprep -d centos7
sudo virsh undefine centos7 

# if you need to change image format
# qemu-img convert -f qcow2 -O raw centos.qcow2 centos.raw
```

### 二、
在kvm虚拟机内进行初始化安装及相关设置，如网卡自动启动，允许root密码登陆，允许注入虚拟机密码，以及userdata支持
```
#!/bin/bash

# on vm !!

sed -i 's#ONBOOT=no#ONBOOT=yes#g' /etc/sysconfig/network-scripts/ifcfg-eth0 
systemctl restart network

# change `PasswordAuthentication` and `PermitRootLogin` in `/etc/ssh/ssh_config`

systemctl restart sshd
yum install -y acpid
systemctl enable acpid

# change `GRUB_CMDLINE_LINUX="crashkernel=auto console=tty0 console=ttyS0,115200n8"` in `/etc/sysconfig/grub`

yum install -y qemu-guest-agent

# change `/etc/sysconfig/qemu-ga` as follows:
# TRANSPORT_METHOD="virtio-serial"
# DEVPATH="/dev/virtio-ports/org.qemu.guest_agent.0"
# LOGFILE="/var/log/qemu-ga/qemu-ga.log"
# PIDFILE="/var/run/qemu-ga.pid"
# BLACKLIST_RPC=""
# FSFREEZE_HOOK_ENABLE=0

echo "NOZEROCONF=yes" >> /etc/sysconfig/network
yum install -y cloud-init
yum update -y
yum install -y epel-release
yum install -y cloud-utils-growpart.x86.64
rpm -qa kernel | sed 's/^kernel-//'  | xargs -I {} dracut -f /boot/initramfs-{}.img {}

cat /dev/null > ~/.bash_history && history -c && shutdown -t now
```

### 三、
在openstack内上传镜像
```
#!/bin/bash

# on controller node !!
# 先在dashboard中创建image并上传镜像文件,  然后执行下面命令设置image属性
glance image-update --disk-format=qcow2 --container-format=bare --property hw_qemu_guest_agent=yes <IMAGE_ID>
```