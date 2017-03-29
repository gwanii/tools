#!/bin/bash
neutron net-create public  --provider:network_type flat --provider:physical_network external --router:external
neutron subnet-create public 192.168.99.0/24 --name public --enable-dhcp=False --allocation-pool start=192.168.99.2,end=192.168.99.254 --gateway 192.168.99.1
