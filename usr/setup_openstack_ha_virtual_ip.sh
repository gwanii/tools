#!/bin/bash
vip=21.20.20.50
ha1_ip=21.20.20.40
ha2_ip=21.20.20.18
subnet=21.20.20.0/24

setup_ha_port() {
  vport=vport_$(echo "$vip"|tr "." "_")
  net_id=$(neutron net-list|grep "$subnet"|awk '{print $2}')
  subnet_id=$(neutron net-list|grep "$subnet"|awk '{print $6}')
  vip_floating=$(neutron floatingip-create public|grep -w floating_ip_address|awk '{print $(NF-1)}')
  vip_floating_id=$(neutron floatingip-create public|grep -w id|awk '{print $(NF-1)}')
  neutron port-create --name "$vport" --fixed-ip subnet_id="$subnet_id",ip_address="$vip" "$net_id"
  vport_id=$(neutron port-list|grep "$vport"|awk '{print $2}')
  neutron floatingip-associate "$vip_floating_id" "$vport_id"

}

update_port() {
  ha1_port_id=$(neutron port-list|grep "$ha1_ip"|awk '{print $2}')
  ha2_port_id=$(neutron port-list|grep "$ha2_ip"|awk '{print $2}')
  neutron port-update --allowed-address-pair ip_address="$vip" "$ha1_port_id"
  neutron port-update --allowed-address-pair ip_address="$vip" "$ha2_port_id"
}

main() {
  setup_ha_port
  update_port
  echo "vip: ${vip}"
  echo "vip's floating ip: ${vip_floating}"
}

main
