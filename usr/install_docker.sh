#!/bin/bash
curl -sSL https://get.docker.com | sudo bash
sudo usermod -aG docker $(whoami)
