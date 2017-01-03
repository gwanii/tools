#!/bin/bash
ansible nova -m ping > ./nova_ping.log
r=$(sed -n '/UNREACHABLE/p' nova_ping.log |awk '{print $1}')
[[ -z $r ]] && echo "all ping OK." || echo "some ping not OK:" && echo $r
