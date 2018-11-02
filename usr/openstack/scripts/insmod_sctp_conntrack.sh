#!/bin/bash
# Enable sctp behind NAT on network node
#modprobe nf_conntrack_proto_sctp
cat >> /etc/modules-load.d/nf_sctp.conf <<EOF
nf_conntrack_proto_sctp
EOF
