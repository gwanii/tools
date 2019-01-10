#!/bin/bash
num=3
for ((i=1; i<=num; i++)) do
  if netstat -ntlp|grep "192.168.9.201:5556"; then
    exit 0
  fi
  sleep 1
done
exit 1
