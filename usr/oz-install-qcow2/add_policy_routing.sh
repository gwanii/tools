#!/bin/bash
# add persistent iproute2 routes and rules
set -x

# change ifname here
NICS=(eth0)
RNUM=101

###################################################################

# Check /etc/sysconfig/network-scripts/{eth0,eth1,eth2} all exists.
# Otherwise, restart network will not work.
# As default, ifcfg-eth0 exists, but others not exists.
for nic in ${NICS[@]}; do

if [[ "$nic" != "eth0" ]]
then
cat <<EOF >> /etc/sysconfig/network-scripts/ifcfg-$nic
IPV6INIT=yes
BOOTPROTO=dhcp
DEVICE=$nic
ONBOOT=yes
EOF
fi

done

function add_policy_routing {
for nic in ${NICS[@]}; do

addr=$(ifconfig $nic | grep "inet " | awk '{print $2}')
gw=$(ip route list dev $nic | grep "default via" | awk '{print $3}')
echo $nic $addr $gw

cat <<EOF >> /etc/iproute2/rt_tables 
$RNUM $nic
EOF
RNUM=$(( $RNUM + 1))

cat <<EOF >> /etc/sysconfig/network-scripts/route-$nic
default via $gw dev $nic table $nic
EOF

cat <<EOF >> /etc/sysconfig/network-scripts/rule-$nic
from $addr table $nic
EOF

done

# sudo yum install -y NetworkManager-config-routing-rules
sudo systemctl restart network
}


# cat <<EOF >> /etc/iproute2/rt_tables
# 101 eth0
# 102 eth1
# EOF
# 
# ip route add default via 10.254.0.1 dev eth0 table eth0
# ip route add default via 172.16.0.1 dev eth1 table eth1
# 
# ip rule add from 10.254.0.4 table eth0
# ip rule add from 172.16.0.4 table eth1

add_policy_routing
