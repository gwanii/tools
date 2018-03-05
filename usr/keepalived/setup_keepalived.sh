#!/bin/bash
[[ ! x$(getenforce) -eq x"Disabled" ]] && setenforce 0
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
which keepalived &> /dev/null || yum install -y keepalived
pushd /etc/keepalived > /dev/null
cat << 'EOF' > keepalived.conf
! Configuration File for keepalived

global_defs {
   router_id ONOS_HA
}

vrrp_script check_onos {
    script "/etc/keepalived/check_onos.sh"
    interval 2
    fall 2
    rise 2
}

vrrp_instance VI_1 {
    state BACKUP
    nopreempt
    interface eth0
    virtual_router_id 41
    priority 150
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass ONOS
    }
    virtual_ipaddress {
        192.168.9.230/24
    }
    track_interface {
        eth0
    }
    track_script {
        check_onos
    }
    notify_master /etc/keepalived/start_onos.sh
    notify 	/etc/keepalived/notify.sh
}
EOF
cat << 'EOF' > start_onos.sh
#!/bin/bash
systemctl start onos
EOF
cat << 'EOF' > check_onos.sh
#!/bin/sh
SERVICE=onos/apache-karaf
NUM_OF_CHECK=3

check_daemon()
{
    ps -ef | grep -v grep | grep $1 > /dev/null
    return $?
}

if check_daemon "$SERVICE"; then
    exit 0
fi
#for (( i=1; i<=$NUM_OF_CHECK; i++ )); do
#    systemctl start $SERVICE
#    sleep 1
#    if check_daemon "$SERVICE"; then
#        exit 0
#    fi
#done
exit 1
EOF
cat << 'EOF' > notify.sh
#!/bin/bash
echo $1 $2 is in $3 state > /var/run/keepalive.$1.$2.state
EOF
chmod 744 *.sh
popd > /dev/null
