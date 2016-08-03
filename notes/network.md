 容器网络方案
 
 - calico; bgp + iptables + ipset
 
 - flannel
 
 - weave
 
 - macvlan/ipvlan
 	
 	* Docker + GORB + MacVLAN network plugin + IPVS DR mode = dream setup
 
 - contiv; openvswitch
 
 - midonet; https://blog.midonet.org/docker-networking-midonet/
 
 - ipsec; 
 
 - fd.io; vpp
 

 - https://www.singlestoneconsulting.com/~/media/files/whitepapers/dockernetworking2.pdf 
 	
 	* One answer is to use a centralized control plane that contains all the destination MAC
addresses of the containers mapped to the real hosts on which they sit. A second choice
is to use multicast, with all the complexity that brings. And lastly, you can use a specialized
protocol to advertise host/mac mappings such as BGP. Fortunately, for this purpose Docker
decided to do a combination of the first and last options . Through the usage of a centralized
key/value store (Etcd, Consul, or Zookeeper) the Docker hosts learn and advertise all the
information needed to facilitate the magic at a management plane level. And the Docker
hosts directly communicate ho