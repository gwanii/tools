#!/bin/bash
ansible bak -m ping
ansible bak -m shell -a "uptime && free -h"
