#!/usr/bin/bash

### source mirror
PLATFORM=$(grep DISTRIB_ID /etc/*-release | awk -F '=' '{print $2}')
VERSION=$(grep "VERSION_ID" /etc/os-release | awk -F "=" '{print $2}' | sed -e 's/^"//' -e 's/"$//')
if [ "$PLATFORM" == "Ubuntu" ]; then
    # TODO
    apt-get update -y && apt-get install -y gcc libffi-dev python-dev libssl-dev vim wget curl git
else
    mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
    yum install -y wget && wget -O /etc/yum.repos.d/CentOS-Base.repo "http://mirrors.aliyun.com/repo/Centos-$VERSION.repo"
    yum update -y && yum install -y gcc libffi-devel python-devel openssl-devel vim curl git
fi

### pip
if [ ! -e /usr/bin/pip ]; then
    yum install -y curl && curl https://bootstrap.pypa.io/get-pip.py| python
    mkdir ~/.pip
    echo -e "[global]\nindex-url=http://pypi.douban.com/simple\ntrusted-host=pypi.douban.com" > ~/.pip/pip.conf
else
    echo "`which pip` is available"
fi

#pip install python-openstackclient
