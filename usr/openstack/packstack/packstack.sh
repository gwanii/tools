#!/bin/bash

# prepare
# yum install -y wget vim
# cp /etc/virc .vimrc
#(maybe not newest) mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
#(maybe not newest) wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
# yum update -y
# curl -sSL https://bootstrap.pypa.io/get-pip.py | python
# mkdir .pip
# cat >> .pip/pip.conf << EOF
# [global]
# index-url=http://pypi.douban.com/simple
# trusted-host=pypi.douban.com
# EOF

systemctl disable firewalld
systemctl stop firewalld
systemctl disable NetworkManager
systemctl stop NetworkManager
systemctl enable network
systemctl start network

# rdo openstack install(on controller node)
yum install -y centos-release-openstack-newton
yum update -y
yum install -y openstack-packstack

ssh-keygen -t rsa
packstack --gen-answer-file=packstack-answers-`date +%Y%m%d-%H%M%S`.txt
#(important) edit packstack answer file !!!
packstack --answer-file=
