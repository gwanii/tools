#!/bin/bash
BEFORE=192.168.99.99
AFTER=$(ifconfig eth0|grep "inet "|awk '{print $2}')
echo "ip will be $AFTER..."
grep -rl $BEFORE /etc | xargs sed -i s#$BEFORE#$AFTER#g 
mysql -Dkeystone -e "update endpoint set url = REPLACE(url, '$BEFORE', '$AFTER');"   # change keystone endpoint, important!!
systemctl restart rabbitmq-server httpd
systemctl restart openstack-nova-*
systemctl restart openstack-glance-api openstack-glance-registry
systemctl restart neutron-server neutron-l3-agent neutron-dhcp-agent neutron-openvswitch-agent
