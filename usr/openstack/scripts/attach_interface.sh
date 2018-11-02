#!/bin/bash
attach_interface() {
  vm_name="$1"
  net_name="$2"
  num="$3"
  vm_id=$(nova list|grep "$vm_name"|head -n 1|awk '{print $2}')
  net_id=$(neutron net-list --sort-key name|grep -E "$net_name"|awk '{print $2}')
  for i in $(seq "$num"); do
    nova interface-attach --net-id="$net_id" "$vm_id"
  done
}

detach_interface() {
  vm_name="$1"
  vm_ip="$2"
  vm_id=$(nova list|grep "$vm_name"|head -n 1|awk '{print $2}')
  port_id=$(neutron port-list|grep "$vm_ip"|head -n1|awk '{print $2}')
  nova interface-detach "$vm_id" "$port_id"
}

#attach_interface bbb-15.22 flat14 1
detach_interface migrate-bbb-15.22 192.168.14.8

# Here is a problem that interface's binded security groups is the default group after attach to instance.
