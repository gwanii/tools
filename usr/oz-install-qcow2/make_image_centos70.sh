#!/bin/bash

# yum install -y oz createrepo pykickstart
# vim /etc/oz/oz.cfg ==> "image_type=qcow2"
# reboot??
# createrepo /root/img/files/repo(the dir include some rpms)
# kill -9 $(netstat -ntlp|grep 8000|cut -d/ -f1|awk '{print $7}')
# cd /root/img/files && sh -c "nohup python -m SimpleHTTPServer > /dev/null &" && cd ..
oz-install -p -u -d3 -a ks.cfg centos70.tdl -t 12000
qemu-img convert -c /var/lib/libvirt/images/centos_70_x86_64.qcow2 -O qcow2 ~/custom.qcow2

# yum install -y guestfish
# export LIBGUESTFS_BACKEND=direct
# guestfish --rw -a custom.qcow2
# run
# list-filesystems
# mount /dev/sda3 /
# mkdir /opt/openstack
# vi /opt/openstack/policy_routing.sh
