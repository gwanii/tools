etcd:

docker run -d -p 4001:4001 -p 2380:2380 -p 2379:2379 \
 --name etcd catalog.shurenyun.com/library/etcd:v2.3.6 \
 -name etcd0 \
 -advertise-client-urls http://192.168.99.107:2379,http://192.168.99.107:4001 \
 -listen-client-urls http://0.0.0.0:2379,http://0.0.0.0:4001 \
 -initial-advertise-peer-urls http://192.168.99.107:2380 \
 -listen-peer-urls http://0.0.0.0:2380 \
 -initial-cluster-token etcd-cluster-1 \
 -initial-cluster etcd0=http://192.168.99.107:2380,etcd1=http://192.168.99.108:2380 \
 -initial-cluster-state new
 
 docker run -d -p 4001:4001 -p 2380:2380 -p 2379:2379 \
 --name etcd catalog.shurenyun.com/library/etcd:v2.3.6 \
 -name etcd1 \
 -advertise-client-urls http://192.168.99.108:2379,http://192.168.99.108:4001 \
 -listen-client-urls http://0.0.0.0:2379,http://0.0.0.0:4001 \
 -initial-advertise-peer-urls http://192.168.99.108:2380 \
 -listen-peer-urls http://0.0.0.0:2380 \
 -initial-cluster-token etcd-cluster-1 \
 -initial-cluster etcd0=http://192.168.99.107:2380,etcd1=http://192.168.99.108:2380 \
 -initial-cluster-state new
 
 

slave:
    - step2. 获取master_ips,  ETCD_ENDPOINTS=master_ips  calicoctl node --libnetwork --node-image --libnetwork-image
    - step3. docker run --cluster-store=  --advertise-url=
    - step4. docker network create -d calico --ipam-driver calico-net
    
    
    

    
ETCD_ENDPOINTS=http://192.168.99.107:2379,http://192.168.99.108:2379 calicoctl status
ETCD_ENDPOINTS=http://192.168.99.107:2379,http://192.168.99.108:2379 calicoctl node --libnetwork
etcdctl --endpoints=192.168.99.107:2379,192.168.99.108:2379 ls



先：
docker run -d --net=host --privileged --name=calico-node -e HOSTNAME=node-01 -e CALICO_NETWORKING=true -e NO_DEFAULT_POOLS=true -e ETCD_SCHEME=http -e ETCD_ENDPOINTS=http://192.168.99.107:2379,http://192.168.99.108:2379 -v /var/log/calico:/var/log/calico -v /lib/modules:/lib/modules -v /var/run/calico:/var/run/calico catalog.shurenyun.com/library/calico-node:v0.20.0

后：
docker run -d --net=host --privileged --name=calico-libnetwork -e HOSTNAME=node-01 -e ETCD_SCHEME=http -e ETCD_ENDPOINTS=http://192.168.99.107:2379,http://192.168.99.108:2379 -v /run/docker/plugins:/run/docker/plugins catalog.shurenyun.com/library/calico-libnetwork:v0.8.0



```
docker run -d -p 2380:2380 -p 2379:2379 \ --name etcd quay.io/coreos/etcd \ -name etcd1 \ -advertise-client-urls http://192.168.99.112:2379 \ -listen-client-urls http://0.0.0.0:2379 \ -initial-advertise-peer-urls http://192.168.99.112:2380 \ -listen-peer-urls http://0.0.0.0:2380 \ -initial-cluster-token etcd-cluster-1 \ -initial-cluster etcd0=http://192.168.99.114:2380,etcd1=http://192.168.99.112:2380,etcd2=http://192.168.99.113:2380 \ -initial-cluster-state new
```

```
wget -L https://github.com/projectcalico/calico-containers/releases/download/v0.20.0/calicoctl
```


```
ETCD_ENDPOINTS=http://192.168.99.107:2379,http://192.168.99.108:2379 NO_DEFAULT_POOLS=true calicoctl node --node-image=catalog.shurenyun.com/library/calico-node:v0.20.0 --libnetwork --libnetwork-image=catalog.shurenyun.com/library/calico-libnetwork:v0.8.0
```




