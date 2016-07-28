LVS: linux virtual server(分为基于IP的请求转发和基于内容的请求转发)

- 案例: docker 1.12 service load balance实现, 可以看到对swarm集群内81端口服务的访问dnat到172.18.0.2:81，
对82端口服务的访问dnat到172.18.0.2:82; 我猜测是到172.18.0.2:81之后再通过IPVS四层负载均衡到容器IP:81


```
$docker service create --name nginx --replicas=3 -p 81:80 nginx:latest
$docker service create --name nginxbak --replicas=3 -p 82:80 nginx:latest
$cat /proc/sys/net/ipv4/ip_forward
$sudo iptables -L DOCKER-INGRESS -t nat
Chain DOCKER-INGRESS (2 references)
target     prot opt source               destination
DNAT       tcp  --  anywhere             anywhere             tcp dpt:81 to:172.18.0.2:81
DNAT       tcp  --  anywhere             anywhere             tcp dpt:82 to:172.18.0.2:82
RETURN     all  --  anywhere             anywhere
$docker network inspect docker_gwbridge

```

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
	
	
