

etcdctl ls --recursive --sort -p /docker

etcdctl ls --sort --recursive -p /docker|awk '/\/$/{print}'

不以／结束的？？

/docker/network/v1.0/endpoint/05cea669a2a48fc745e1dc23a374b8c2c42350ddff020f53f32877ed07fe073c/ 是什么？？

calico是否清除iptables



### 线索：

查看etcd

查看calico/libnetwork容器日志

查看calico/node日志:/var/log/calico

### 入口

calico.felix.felix:main

