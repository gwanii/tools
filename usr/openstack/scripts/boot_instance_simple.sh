#!/bin/bash

set -x

INSTANCE_NAME=test
FLAVOR_NAME=cirros
NETWORK_NAME="oam"  # network names seperate by vertical bar
IMAGE_NAME=centos

IMAGE_ID=$(nova image-list|grep $IMAGE_NAME|awk '{print $2}')
NETWORK_IDS=$(neutron net-list --sort-key name|grep -E "$NETWORK_NAME"|awk '{print $2}')

########################################################################################

function boot_instance {
    nics=""
    for ID in $NETWORK_IDS; do
        nics="--nic net-id=$ID $nics"
    done

    nova boot \
    --flavor $FLAVOR_NAME \
    --image $IMAGE_NAME \
    $nics \
    $INSTANCE_NAME
}

# function associate_floatingip {
# }

boot_instance
# associate_floatingip
nova list

# nova floating-ip-associate --fixed-address 22.22.22.22 test 192.168.22.22
