#!/bin/bash
USER=ubuntu

sudo_no_passwd() {
  grep -q "^$USER:" /etc/passwd || sudo adduser "$USER"
  sudo usermod -a -G sudo "$USER" && \
  echo "${USER} ALL=(ALL) NOPASSWD:ALL" | sudo tee --append /etc/sudoers.d/90-cloud-init-users
}

sudo_no_passwd
