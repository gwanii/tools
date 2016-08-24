#!/bin/bash
nohup flanneld -etcd-endpoints="http://127.0.0.1:4001,http://127.0.0.1:2379" -iface=enp0s3 > ~/log/flannel.log &
