#!/usr/bin/bash

### source mirror
PLATFORM=$(grep DISTRIB_ID /etc/*-release | awk -F '=' '{print $2}')
VERSION=$(grep "VERSION_ID" /etc/os-release | awk -F "=" '{print $2}' | sed -e 's/^"//' -e 's/"$//')
if [[ "$PLATFORM" == "Ubuntu" ]]; then
    # TODO
    apt-get update -y && apt-get install -y gcc gcc-c++ libffi-dev python-dev libssl-dev vim wget curl git
else
    yum install -y wget		
    mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
    wget -O /etc/yum.repos.d/CentOS-Base.repo "http://mirrors.aliyun.com/repo/Centos-$VERSION.repo"
    yum update -y && yum install -y gcc gcc-c++ make libtool openssl openssl-devel libffi-devel python-devel pcre pcre-devel readline readline-devel vim curl git net-tools brctl-tools lsof nc
fi

### pip
if [[ ! -e /usr/bin/pip ]]; then
    yum install -y curl && curl https://bootstrap.pypa.io/get-pip.py| python
    if [ ! -e ~/.pip/pip.conf ]; then
        mkdir ~/.pip
        echo -e "[global]\nindex-url=http://pypi.douban.com/simple\ntrusted-host=pypi.douban.com" > ~/.pip/pip.conf
    else
        echo "pip.conf always exists."
    fi
else
    echo "`which pip` is available"
fi

### node.js
git clone https://github.com/cnpm/nvm.git ~/.nvm
echo -e "\n#node.js \nsource ~/.nvm/nvm.sh" >> ~/.bashrc
npm install cnpm -g --registry=http://registry.npm.taobao.org
#npm install microtime \
#  --registry=http://registry.npm.taobao.org \
#  --disturl=http://npm.taobao.org/mirrors/node
