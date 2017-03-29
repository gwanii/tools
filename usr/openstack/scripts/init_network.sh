#!/bin/bash

EXTERNAL_NETWORK_NAME=public
ROUTER_NAME=router_test
NETWORK_NAME=private2
SUBNET_NAME=private2_subnet1
SUBNET_CIDR=172.16.0.0/24


# create router and set gateway
function create_router {
    neutron router-create $ROUTER_NAME
    ROUTER_ID=$(neutron router-list | grep $ROUTER_NAME | awk '{print $2}')
    neutron router-gateway-set ROUTER_ID EXTERNAL_NETWORK_NAME
}

# create network and subnet
function create_subnet {
    ROUTER_ID=$(neutron router-list | grep $ROUTER_NAME | awk '{print $2}')
    neutron net-create $NETWORK_NAME
    neutron subnet-create --name $SUBNET_NAME $NETWORK_NAME $SUBNET_CIDR
    SUBNET_ID=$(neutron subnet-list | grep $SUBNET_NAME | awk '{print $2}')
    neutron router-interface-add $ROUTER_ID $SUBNET_ID
}
