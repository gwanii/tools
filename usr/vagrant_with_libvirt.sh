#!/bin/bash
if [ ! -x "/usr/bin/vagrant" ]; then
  echo "Installing vagrant and associated tools..."
  sudo apt-get -y install qemu-kvm libvirt-bin libvirt-dev
  sudo adduser $USER libvirtd

  VAGRANT_SHA256SUM="faff6befacc7eed3978b4b71f0dbb9c135c01d8a4d13236bda2f9ed53482d2c4"  # version 1.9.3
  curl -o /tmp/vagrant.deb https://releases.hashicorp.com/vagrant/1.9.3/vagrant_1.9.3_x86_64.deb
  echo "$VAGRANT_SHA256SUM  /tmp/vagrant.deb" | sha256sum -c -
  sudo dpkg -i /tmp/vagrant.deb
fi

echo "Installing vagrant plugins if needed..."
vagrant plugin list | grep -q vagrant-libvirt || vagrant plugin install vagrant-libvirt --plugin-version 0.0.35
vagrant plugin list | grep -q vagrant-mutate || vagrant plugin install vagrant-mutate
vagrant plugin list | grep -q vagrant-hosts || vagrant plugin install vagrant-hosts

function add_box() {
  if ! vagrant box list | grep -q $1.*libvirt; then
    vagrant box list | grep $1 | grep virtualbox || vagrant box add $1
    vagrant box list | grep $1 | grep libvirt || vagrant mutate $1 libvirt --input-provider virtualbox
  fi
}

add_box centos/7
