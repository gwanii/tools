LVS: linux virtual server(分为基于IP的请求转发和基于内容的请求转发)

- 案例: docker 1.12 service load balance实现, 可以看到对swarm集群内81端口服务的访问dnat到172.18.0.2:81，
对82端口服务的访问dnat到172.18.0.2:82; 我猜测是到172.18.0.2:81之后再通过IPVS四层负载均衡到容器IP:81


```
$docker service create --name nginx --replicas=3 nginx:latest(注意没有加端口映射)
$docker service create --name nginxbak --replicas=3 nginx:latest
$cat /proc/sys/net/ipv4/ip_forward

$docker exec -it <swarm_container_id> ip a
只有172.17.0.0/16段也就是对应docker0的网卡，这是默认local bridge network创建的。
$ip a可看到对应在主机的veth pair interface
$docker network inspect bridge
可验证上面
$docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
66427219132c        bridge              bridge              local
675158c86eaf        docker_gwbridge     bridge              local
05cea669a2a4        host                host                local
35mzhqto2zm2        ingress             overlay             swarm
49183d16d207        none                null                local
$docker network inspect ingress
[
    {
        "Name": "ingress",
        "Id": "35mzhqto2zm2lws041qw77qid",
        "Scope": "swarm",
        "Driver": "overlay",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "10.255.0.0/16",
                    "Gateway": "10.255.0.1"
                }
            ]
        },
        "Internal": false,
        "Containers": {
            "ingress-sbox": {
                "Name": "ingress-endpoint",
                "EndpointID": "d375ecc7c72eadf0305bf8d914eb667b264ad241c000a6ce55761b07b748cf47",
                "MacAddress": "02:42:0a:ff:00:03",
                "IPv4Address": "10.255.0.3/16",
                "IPv6Address": ""
            }
        },
        "Options": {
            "com.docker.network.driver.overlay.vxlanid_list": "256"
        },
        "Labels": {}
    }
]
$docker network inspect docker_gwbridge
[
    {
        "Name": "docker_gwbridge",
        "Id": "675158c86eafb89e4c2b3665295cbaa673643db5ecee2b123b249a9fd62ef08b",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.18.0.0/16",
                    "Gateway": "172.18.0.1/16"
                }
            ]
        },
        "Internal": false,
        "Containers": {
            "ingress-sbox": {
                "Name": "gateway_ingress-sbox",
                "EndpointID": "58a5dac7dc41cefa7a7ec169b779c57ff827dbb816b622c54372cc66ba3085ce",
                "MacAddress": "02:42:ac:12:00:02",
                "IPv4Address": "172.18.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {
            "com.docker.network.bridge.enable_icc": "false",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.name": "docker_gwbridge"
        },
        "Labels": {}
    }
]
查看swarm ingress network(10.255.0.0/16), local docker_gwbridge network(172.18.0.0/16), 发现二者
都包含同一个容器ingress-sbox, 但是docker ps -a|grep ingress-sbox却看不到容器信息, 而且没法ping通10.255.0.0/16网段的ip, 很诡异啊, docker image也看不到任何相关image; 从ip a结果来看又一个ingress-sbox的docker_gwbridge网段的veth pair interface, 说明在ingress swarm network没有创建veth??? docker service create 创建的容器只在docker0创建veth pair；；；一定注意service容器并没有用overlay网络，overlay网络只是用在load balance上了

目前来看退出swarm模式后ingress和docker_gwbridge两个网络还在。ingress-sbox容器还在？
这种情况下没有加端口映射，，，，那么service入口在哪？？？

IP:81  iptables-->  172.18.0.2:81  ipvs-->    


下面是加端口映射的情况
$docker service create --name nginx --replicas=3 -p 81:80 nginx:latest(注意有加端口映射)
$docker exec 5555d29bee1c ip a 容器内网卡情况变了。。。（之前是docker0,现在是ingress和docker_gwbridge）
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
43: eth0@if44: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP group default
    link/ether 02:42:0a:ff:00:06 brd ff:ff:ff:ff:ff:ff
    inet 10.255.0.6/16 scope global eth0
       valid_lft forever preferred_lft forever
    inet 10.255.0.5/32 scope global eth0(为什么两个地址？？？？这个地址在其他容器也有？？？)
       valid_lft forever preferred_lft forever
    inet6 fe80::42:aff:feff:6/64 scope link
       valid_lft forever preferred_lft forever
45: eth1@if46: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:ac:12:00:03 brd ff:ff:ff:ff:ff:ff
    inet 172.18.0.3/16 scope global eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::42:acff:fe12:3/64 scope link
       valid_lft forever preferred_lft forever
$sudo iptables -L DOCKER-INGRESS -t nat
Chain DOCKER-INGRESS (2 references)
target     prot opt source               destination
DNAT       tcp  --  anywhere             anywhere             tcp dpt:81 to:172.18.0.2:81
RETURN     all  --  anywhere             anywhere



host(192.168.99.100:81) iptables--> 172.168.0.2:81(local) 
host(192.168.99.102:81) iptables--> 172.168.0.2:81(local)


```

- 源码分析

	* daemon/network.go:169:, :125:, :161:
	
	* vendor/src/github.com/docker/swarmkit/manager/allocator/network.go:23:


- 介绍

	* http://www.tomshine.xyz/2016/05/06/lvs%E4%BB%8B%E7%BB%8D%E5%92%8C%E4%BD%BF%E7%94%A8/

	* https://www.ibm.com/developerworks/cn/linux/cluster/lvs/part1/

	* https://www.ibm.com/developerworks/cn/linux/cluster/lvs/part2/

	* https://www.ibm.com/developerworks/cn/linux/cluster/lvs/part3/

	* https://www.ibm.com/developerworks/cn/linux/cluster/lvs/part4/


- IPVS
	
	* VS/NAT, Network Address Translation; 修改请求报文的目的IP地址，修改响应报文的源IP地址; cpu bound
	
	* VS/TUN, IP Tunneling; 只对请求报文通过IP隧道转发到真实服务器, 无需处理响应报文; network IO bound
	
	* VS/DR, Direct Routing; 修改请求报文MAC地址, 响应报文直接返回客户; 开销小但对限制在同一个物理网络
	
- KTCPVS
	
	* simple http, persistent http, cookie-based http, hash-based http 
	
- route mesh

	* redirect
	
- tcpdump tcp -i eth1 -t -s 0 -c 100 and dst port ! 22 and src net 192.168.1.0/24 -w ./target.cap

- overlay netwrok port:

	* vxlan: UDP 4789(data plane)

	* serf: TCP + UDP 7946(control plane)
		
		
- firewalld

	* https://havee.me/linux/2015-01/using-firewalls-on-centos-7.html
	
	* http://www.lxy520.net/2016/07/02/shi-yong-docker-1-12-da-jian-duo-zhu-ji-docker-swarmji-qun/
	



	
	
