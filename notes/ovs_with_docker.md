OpenvSwitch with Docker

http://www.cnblogs.com/yuuyuu/p/5180827.html
http://qiankunli.github.io/2016/05/27/docker_network3.html


- install

	*  wget http://openvswitch.org/releases/openvswitch-2.5.0.tar.gz
	
	* tar xf
	
	* yum install gcc make python-devel openssl-devel kernel-devel graphviz kernel-debug-devel autoconf automake rpm-build redhat-rpm-config libtool
	
	*  ./configure --with-linux=/lib/modules/`uname -r`/build
	
- tools

	* net-tools: ifconfig, route, arp, nestat; 起源于BSD TCP/IP
	
	* iproute2: net-tools可以通过procfs（/proc）和ioctl系统调用，访问和更改内核网络配置，iproute2则通过网络链路套接字接口与内核进行联系

$brctl show ; 展示linux网桥, 可查看br0下的interfaces

veth pair相当于指定docker0为default gateway



$sudo docker run --net=none --privileged=true -it ubuntu
$sudo ./ovs-docker add-port vxbr eth0 b062406bc6b6



- ovs-docker如何实现???

	* ip link set "${PORTNAME}_c" netns "$PID" 直接在namespace里操作


