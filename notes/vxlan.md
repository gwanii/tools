VXLAN

- 24bit-->16million

- VXLAN Tunnel Endpoint(VTEP): frame encapsulation

- VXLAN on Linux bridge supported in 2012

- 1450 MTU, 50 byte for vxlan header

- ln -s /var/run/docker/netns/ /var/run/netns

- ln -s /proc/5291/ns/net /var/run/netns/5291

-  docker inspect 3f3d5c0c3fbc |grep "SandboxKey"





