driver

network interface: 	create/delete network
endpoint interface: create/delete network
state driver: etcd, consul, zookeeper等
plugin: north-bound提供接口，south-bound调用driver接口；负责维护状态，资源分配回收约束



OvsCfgEndpointState
OvsOperEndpointState
OvsCfgNetworkState
OvsOperNetworkState
