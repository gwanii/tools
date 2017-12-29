#!/bin/bash
install_epc() {
virt-copy-in mme -a vepc.img /usr/local/bin/
virt-copy-in sgw -a vepc.img /usr/local/bin/
virt-copy-in pgw -a vepc.img /usr/local/bin/
virt-copy-in start_mme.sh -a vepc.img /usr/local/bin/
virt-copy-in start_sgw.sh -a vepc.img /usr/local/bin/
virt-copy-in start_pgw.sh -a vepc.img /usr/local/bin/
}

network_config() {
virt-copy-in interfaces -a vepc.img /etc/network/
virt-copy-in if-pre-up-upstart-faker -a vepc.img /etc/network/if-pre-up.d/
}

cloud_init_config() {
virt-copy-in cloud.cfg -a vepc.img /etc/cloud/cloud.cfg
}

network_config
