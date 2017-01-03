#!/bin/bash
set -x

NICS=$(ip -o a|grep -E "inet 21|inet 22"|awk '{print $2}')
RNUM=100

NNICS=$(echo $NICS|wc -w)
[[ "$NNICS" -eq 0 ]] && echo "No nic needs floatingip." && exit 0
ip route list |grep "default"|grep -v -E "via 21|via 22"|xargs ip route delete
[[ "$NNICS" -eq 1 ]] && echo "One nic needs floatingip." && exit 0
echo "Multi nics need floatingip, generate policy routing rules."

for nic in $NICS; do
cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-$nic
IPV6INIT=yes
BOOTPROTO=dhcp
DEVICE=$nic
ONBOOT=yes
EOF
done

function add_policy_routing {
for nic in $NICS; do
addr=$(ifconfig $nic | grep "inet " | awk '{print $2}')
gw=$(ip route list dev $nic | grep "default via" | awk '{print $3}')
echo $nic $addr $gw

cat <<EOF >> /etc/iproute2/rt_tables
$RNUM$(echo $nic|cut -dh -f2) $nic
EOF

cat <<EOF > /etc/sysconfig/network-scripts/route-$nic
default via $gw dev $nic table $nic
EOF

cat <<EOF > /etc/sysconfig/network-scripts/rule-$nic
from $addr table $nic
EOF

done

systemctl restart network
}

add_policy_routing
