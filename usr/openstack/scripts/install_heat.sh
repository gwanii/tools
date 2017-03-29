#!/bin/bash

HEAT_PASS=heat_pass

yum install -y openstack-heat-api openstack-heat-engine
mysql -uroot -e "create database heat;"
mysql -uroot -e "grant all privileges on heat.* to 'heat'@'localhost' identified by '$HEAT_PASS';"
mysql -uroot -e "grant all privileges on heat.* to 'heat'@'%' identified by '$HEAT_PASS';"
# vim /etc/heat/heat.conf
# db, mq, auth

su -s /bin/sh -c "heat-manage db_sync" heat


openstack user create --domain default --password-prompt heat
openstack role add --project service --user heat admin
openstack service create --name heat --description "Orchestration" orchestration
openstack endpoint create --region RegionOne \
--publicurl http://192.168.9.9:8004/v1/%\(tenant_id\)s \
--internalurl http://192.168.9.9:8004/v1/%\(tenant_id\)s \
--adminurl http://192.168.9.9:8004/v1/%\(tenant_id\)s \
orchestration

openstack role create heat_stack_owner
openstack role add --project test --user test heat_stack_owner
openstack role add --project admin --user admin heat_stack_owner
openstack role create heat_stack_user

systemctl start openstack-heat-engine openstack-heat-api
