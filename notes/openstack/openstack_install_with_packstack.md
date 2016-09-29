## 使用RDO Packstack部署OpenStack Mitaka

### 一、准备工作

1. 硬件选型

2. 网络规划
    
    - 控制节点(1 nics)
        - 管理网络: 10.10.10.10(eth0)
    - 计算节点(2 nic)
        - 管理网络: 10.10.10.11(eth0)
        - 虚拟机网络(tunnels): 10.10.10.12(eth1)
    - 网络节点(3 nic)
        - 管理网络: 10.10.10.13(eth0)
        - 虚拟机网络(tunnels): 10.10.10.14(eth1)
        - 外部网络: 10.10.10.15(eth2)

3. 系统安装

    - 系统分区建议
        - 对存储节点: 参照http://docs.openstack.org/mitaka/install-guide-rdo/cinder-storage-install.html
        - 对计算节点: 建议将/var目录单独挂载到足够大的分区, 因为/var/lib/nova下存放虚拟机数据  


### 二、安装

```
#!/bin/bash

# 设置CentOS源
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum update -y
# 安装pip并设置pip源
curl -sSL https://bootstrap.pypa.io/get-pip.py | python
mkdir .pip
cat >> .pip/pip.conf << EOF
[global]
index-url=http://pypi.douban.com/simple
trusted-host=pypi.douban.com
EOF

systemctl disable firewalld
systemctl stop firewalld
systemctl disable NetworkManager
systemctl stop NetworkManager
systemctl enable network
systemctl start network

# rdo openstack install(on controller node)
yum install -y centos-release-openstack-mitaka
yum update -y
yum install -y openstack-packstack

ssh-keygen -t rsa
packstack --gen-answer-file=packstack-answers-`date +%Y%m%d-%H%M%S`.txt
#(important) edit packstack answer file !!!
packstack --answer-file=packstack-answers-20160907-102647.txt
```
 ntp安装
```
#!/bin/bah

# 一般在控制节点上安装NTP, 然后让其他节点时间与控制节点保持同步
# on controller node
yum install ntp

cat <<EOF >> /etc/ntp.conf
restrict -4 default kod notrap nomodify
restrict -6 default kod notrap nomodify
EOF

systemctl enable ntpd && systemctl restart ntpd


# on other nodes
yum install ntp

sed -i 's/^server/#server/g' /etc/ntp.conf
echo "server 192.168.9.122 iburst" >> /etc/ntp.conf

systemctl enable ntpd && systemctl restart ntpd

```

### 三、packstack answerfile配置说明
下面简要介绍一些重要的配置项
```
CONFIG_DEFAULT_PASSWORD=  # 默认密码

EXCLUDE_SERVERS=  # 如果有的计算节点已经安装配置好了, 不想配置被覆盖, 可以在这里设置IP

CONFIG_DEBUG_MODE=  # 是否开启服务调试模式, 生产环境建议选n

CONFIG_CONTROLLER_HOST=<controller_mgnnet_ip>  # 控制节点管理网段IP
CONFIG_COMPUTE_HOSTS=<compute_mgnnet_ips>  # 计算节点管理网段IP列表, 以逗号分隔
CONFIG_NETWORK_HOSTS=<network_mgnnet_ip>  # 网络节点管理网段IP

CONFIG_MARIADB_HOST=  # MySQL所在主机IP，一般设置为控制节点管理网段IP

CONFIG_KEYSTONE_REGION=RegionOne
# Token to use for the Identity service API.
CONFIG_KEYSTONE_ADMIN_TOKEN=7fa0990cd247405ea9dae9ad5cc72e51
CONFIG_KEYSTONE_API_VERSION=v2.0  # keystone版本

CONFIG_GLANCE_BACKEND=file  # glance后端存储; 对应/etc/glance/glance-registry.conf中[glance_store]下的配置项default_store

CONFIG_NEUTRON_L3_EXT_BRIDGE=br-ex  # 网络节点ovs外部网桥名
CONFIG_NEUTRON_ML2_TYPE_DRIVERS=flat,vlan,gre,vxlan  # neutron支持的网络拓扑driver; 对应控制节点上/etc/neutron/plugins/ml2/ml2_conf.ini中[ml2]下的配置项type_drivers
CONFIG_NEUTRON_ML2_TENANT_NETWORK_TYPES=vxlan  # tenant network类型; 对应控制节点上/etc/neutron/plugins/ml2/ml2_conf.ini中[ml2]下的配置项tenant_network_types 
CONFIG_NEUTRON_ML2_FLAT_NETWORKS=external  # when useing flat topology(such as provider network); 对应控制节点上/etc/neutron/plugins/ml2/ml2_conf.ini中[ml2_type_flat]下的配置项flat_networks
CONFIG_NEUTRON_OVS_BRIDGE_IFACES=br-ex:<network_extnet_ifname>  # br-ex网桥与物理网卡映射; 对应网络节点上/etc/neutron/plugins/ml2/openvswitch_agent.ini中[ovs]下的配置项bridge_mappings
CONFIG_NEUTRON_OVS_TUNNEL_IF=<tunnet_ifname>  # when using vxlan/gre topology; 虚拟机网络网卡名; 猜测packstack根据网卡名设置计算/网络节点上/etc/neutron/plugins/ml2/openvswitch_agent.ini中[ovs]下的配置项local_ip

CONFIG_PROVISION_DEMO=n  # 是否创建demo账户
```

### 其他
1. bash completion: 以neutron为例, https://github.com/openstack/python-neutronclient/blob/master/tools/neutron.bash_completion
2. 存储节点配置: 可参考http://docs.openstack.org/mitaka/install-guide-rdo/cinder-storage-install.html
3. Q: dashboard中web console报错"Failed to connect to server (code: 1006)" A: hosts没设置好, 参照https://ask.openstack.org/en/question/520/vnc-console-in-dashboard-fails-to-connect-ot-server-code-1006/
4. Q: 如何创建用于提供floatingip的external network? A: 参照https://www.rdoproject.org/networking/floating-ip-range/ 或者参照下面我的总结
```
# 先规划一个连续公网网段, 可借助namp工具
neutron net-create public --provider:network_type flat --provider:physical_network external --router:external
neutron subnet-create public 192.168.9.0/24 --name flat --enable-dhcp=False --allocation-pool start=192.168.9.160,end=192.168.9.175 --gateway 192.168.9.1
neutron route-create router1
neutron route-gateway-set $router_id $net_id
```
5. Q: 虚拟机ping baidu.com不通? A: 到subnet里面配置dns
6. Q: 多网卡主机为每个网卡设置一个floatingip, 只有一个floatingip能访问？ A: 默认路由问题, 建议使用基于策略路由; 参考http://memoryboxes.github.io/blog/2014/12/30/linuxshuang-wang-qia-shuang-lu-you-she-zhi/
7. Q: 如何disable源地址检查? A: 参考http://blog.csdn.net/matt_mao/article/details/19417451
8. Q: 为什么nova hypervisor-show compute-1显示local_gb不正常？ A: 计算节点/var目录应该单独挂盘
9. Q: 虚拟机无法root密码登陆？ A: 创建虚拟机时设置userdata如下
```
#!/bin/sh
sed -i 's#PasswordAuthentication no#PasswordAuthentication yes#g' /etc/ssh/sshd_config
systemctl restart sshd
```
10. ...
