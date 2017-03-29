#!/bin/bash

PUBLIC=public
USERDATA=user_data.sh
INSTANCE_NAME=test1
FLAVOR_NAME=m1.tiny
NETWORK_NAME="private1|private2"  # network names seperate by vertical bar
IMAGE_NAME=cirros
SECGROUP=default
IMAGE_ID=$(nova image-list|grep $IMAGE_NAME|awk '{print $2}')
NETWORK_IDS=$(neutron net-list --sort-key name|grep -E "$NETWORK_NAME"|awk '{print $2}')


# boot instance
function boot_instance {
    nics=""
    for ID in $NETWORK_IDS; do
        echo $ID
        nics="--nic net-id=$ID $nics"
    done
    echo $nics

    nova boot \
    --flavor $FLAVOR_NAME \
    --image $IMAGE_NAME \
    $nics \
    --security-groups $SECGROUP \
    --user-data $USERDATA $INSTANCE_NAME
}

# associate floatingip
function associate_floatingip {
    FLOATINGS=($(neutron floatingip-list | grep -v -E "\+|floating_ip_address" | awk '{print $5}' | grep -v "|"))
    NUM_FLOATINGS=${#FLOATINGS[@]}
    
    FIXED=($(nova interface-list $INSTANCE_NAME | grep "ACTIVE" | awk '{print $8}'))
    NUM_FIXED=${#FIXED[@]}
    
    MINUS=$(( $NUM_FIXED - $NUM_FLOATINGS))
    if [[ "$MINUS" -gt "0" ]]; then
        for i in `seq 1 $MINUS`; do
            neutron floatingip-create $PUBLIC
        done
    fi
    neutron floatingip-list
    
    set -x
    for i in `seq 0 $(($NUM_FIXED-1))`; do
       nova floating-ip-associate --fixed-address=${FIXED[$i]} $INSTANCE_NAME ${FLOATINGS[$i]}
    done
}

nova list
