#!/bin/bash
# link: https://www.jianshu.com/p/c92c3c9a2d6f

# wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.141-1/virtio-win-0.1.141.iso
# wget https://cloudbase.it/downloads/CloudbaseInitSetup_0_9_11_x64.msi
# yum install -y libvirt virt-install virt-viewer libguestfs-tools
virsh destroy windows10 && virsh undefine windows10 || :
mkisofs -o CloudbaseInitSetup_0_9_11_x64.iso CloudbaseInitSetup_0_9_11_x64.msi
qemu-img create -f qcow2 win10-x86_64.qcow2 10G
virt-install \
    --name=windows10 \
    --ram=4096 \
    --cpu=host \
    --vcpus=2 \
    --os-type=windows \
    --os-variant=win8.1 \
    --disk $PWD/win10-x86_64.qcow2,bus=virtio \
    --disk $PWD/cn_windows_10_enterprise_x64_dvd_6846957.iso,device=cdrom,bus=ide \
    --disk $PWD/virtio-win-0.1.141.iso,device=cdrom,bus=ide \
    --disk $PWD/CloudbaseInitSetup_0_9_11_x64.iso,device=cdrom,bus=ide \
    --network network=default,model=virtio \
    --graphics vnc,listen=0.0.0.0
virt-sparsify --compress ./win10-x86_64.qcow2 Windows-10-x86_64.qcow2
