iptables -I neutron-openvswi-s6c1254a2-5 2 -s 172.24.0.1/32 -m mac --mac-source FA:16:3E:E8:24:F2 -m comment --comment Allow traffic from defined IP/MAC pairs. -j RETURN
iptables --line-number -vnL neutron-openvswi-s6c1254a2-5
