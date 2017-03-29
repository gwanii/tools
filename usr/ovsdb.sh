#!/bin/bash
pkill ovsdb-server
/usr/local/sbin/ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock --remote=ptcp:6640 --remote=db:Open_vSwitch,Open_vSwitch,manager_options --private-key=db:Open_vSwitch,SSL,private_key --certificate=db:Open_vSwitch,SSL,certificate --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert --pidfile --detach
ovs-vsctl show
netstat -ntlp|grep 6640

#ovs-appctl -t ovsdb-server ovsdb-server/add-remote ptcp:6640
