#!/bin/bash
# Thanks for scottlowe's blog: https://blog.scottlowe.org/2018/01/30/running-ovs-fedora-atomic-host/
sudo docker run -itd --net=host --name=ovsdb-server -v var-lib-ovs:/var/lib/openvswitch -v var-log-ovs:/var/log/openvswitch -v var-run-ovs:/var/run/openvswitch -v etc-ovs:/etc/openvswitch keldaio/ovs ovsdb-server
sudo docker run -itd --net=host --name=ovn-northd --volumes-from=ovsdb-server keldaio/ovs ovn-northd
sudo docker run -itd --net=host --name=ovn-controller --volumes-from=ovsdb-server keldaio/ovs ovn-controller
sudo docker run -itd --net=host --name=ovs-vswitchd --volumes-from=ovsdb-server --privileged keldaio/ovs ovs-vswitchd
