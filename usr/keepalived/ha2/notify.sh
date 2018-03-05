#!/bin/bash
echo $1 $2 is in $3 state > /var/run/keepalive.$1.$2.state
