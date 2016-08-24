nohup kube-apiserver --logtostderr=true --v=0 --etcd_servers=http://192.168.1.94:2379 --insecure-bind-address=0.0.0.0 --allow_privileged=false  --service-cluster-ip-range=10.254.0.0/16 --v=0 > /var/log/kubernetes/kube-apiserver 2>&1 &
nohup kube-controller-manager --logtostderr=true --v=0 --master=http://192.168.2.10:8080 --v=0 --node-monitor-grace-period=10s --pod-eviction-timeout=10s > /var/log/kubernetes/kube-controller-manager 2>&1 &
nohup kube-scheduler --logtostderr=true --v=0 --master=http://192.168.2.10:8080 > /var/log/kubernetes/kube-scheduler 2>&1 &
