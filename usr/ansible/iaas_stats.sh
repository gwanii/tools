#!/bin/bash
ansible iaas -m ping
ansible iaas -m shell -a "uptime && free -h"
