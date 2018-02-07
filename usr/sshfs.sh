#!/bin/bash
sshfs rpm@192.168.14.11:/home/rpm /home/hhh/.bridgy/mounts/rpm -o auto_cache,reconnect,no_readahead -C -o TCPKeepAlive=yes -o ServerAliveInterval=255 -o StrictHostKeyChecking=no
sudo umount /home/hhh/.sshfs/rpm
