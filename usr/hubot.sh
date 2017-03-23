#!/bin/bash
if [ ! -d ~/.nvm ]; then
  git clone https://github.com/cnpm/nvm.git .nvm && echo -e "\n# nvm\nsource ~/.nvm/nvm.sh" >> ~/.bashrc
fi
source ~/.nvm/nvm.sh
nvm install v5.9.0
npm install cnpm -g --registry=http://registry.npm.taobao.org
npm install -g coffee-script
npm install -g yo generator-hubot --registry=http://registry.npm.taobao.org --unsafe-perm
