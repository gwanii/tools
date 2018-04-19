#!/bin/bash
HOSTS=/etc/hosts
MARK="# Purified DNS"

sudo sed -i'.bak'  "/^$MARK\$/,\$d" "$HOSTS"
echo "$MARK" | sudo tee -a "$HOSTS" > /dev/null
curl -sSL https://coding.net/u/scaffrey/p/hosts/git/raw/master/hosts-files/hosts | sudo tee -a "$HOSTS" > /dev/null
