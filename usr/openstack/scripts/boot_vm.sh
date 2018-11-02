#!/bin/bash
#set -x
function bootvm {
    set -x 
    net_ids=$(neutron net-list --sort-key name|grep -E "$4"|awk '{print $2}')
    nics=""
    for net_id in ${net_ids}; do
        nics="--nic net-id=$net_id $nics"
    done
    nova boot \
    --flavor "$2" \
    --image "$3" \
    --security-groups "bbb" \
    ${nics} \
    "$1"
}

#nova boot --flavor m1.large --image migrate-wwwww-15.22 --security-groups bbb --nic net-id=f5d1e949-f30a-4839-9420-0bca4abedf1a,v4-fixed-ip=192.168.14.20 migrate-wwwww-15.22
#bootvm test-$(uuidgen) m1.medium mmm-15.21 "flat14"
#bootvm hhh m1.large centos-7.0-desktop "flat14"
bootvm migrate-wwwww-15.22 m1.large migrate-wwwww-15.22 "flat14"

## function boot_migrated_vm {
##   exclude_images="mmm|www"
##   
##   for image in $(glance image-list|grep migrate|grep -vE "$exclude_images"|awk '{print $2"#"$4}'|grep "-"|grep -v ID); do
##     name=$(echo "$image"|cut -d# -f2)
##     echo "- Booting $name"
##     bootvm "$name" m1.large "$name" "flat14"
##     echo "---"
##   done
## }
##boot_migrated_vm
